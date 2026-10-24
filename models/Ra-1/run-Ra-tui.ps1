<#
.SYNOPSIS
  Ra-1 launcher with a live terminal dashboard for llama-server (Windows PowerShell 5.1+ / PowerShell 7).

.DESCRIPTION
  - Preflight checks (llama-server, model file, port, nvidia-smi)
  - Live dashboard: state, uptime, endpoints, GPU util/VRAM/temp/power, tokens/s, request count
  - Scrolling log pane with colour coding and a filtered view
  - Hotkeys: Q quit | R restart | O open web UI | C copy URL | L toggle log filter
  - Clean shutdown (Ctrl+C or Q) - no orphaned llama-server process

  ASCII-only source on purpose: no encoding problems in PowerShell 5.1.
#>
[CmdletBinding()]
param(
    [string]$LlamaDir  = "A:\llama-cpp",
    [string]$ModelPath = "A:\.lmstudio\Akhet\Ra-1\Ra-1-4B-Q4_K_M.gguf",
    [string]$Alias        = "Akhet-Ra-1",
    [string]$SystemPrompt = "A:\.lmstudio\Akhet\Ra-1\system_prompt.txt",
    [int]$GpuLayers       = 99,       # full GPU offload (fits in 6GB VRAM)
    [int]$ContextSize     = 32768,    # 32K context
    [int]$Threads         = 8,
    [int]$Port            = 8080,
    [string]$ApiKey       = "",       # optional: protects the endpoint when exposed on LAN
    [switch]$LocalOnly                # bind 127.0.0.1 instead of 0.0.0.0
)

Set-StrictMode -Off
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- glyphs (ASCII-safe)
$FULL  = [string][char]0x2588
$EMPTY = [string][char]0x2591
$RULE  = [string][char]0x2500
$DOT   = [string][char]0x25CF

# ---------------------------------------------------------------- state
$script:Exe       = Join-Path $LlamaDir "llama-server.exe"
$script:BindHost  = if ($LocalOnly) { "127.0.0.1" } else { "0.0.0.0" }
$script:Proc      = $null
$script:Queue     = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
$script:Log       = New-Object System.Collections.Generic.List[string]
$script:Healthy   = $false
$script:Busy      = $false
$script:Offload   = ""
$script:Requests  = 0
$script:GenTokens = 0
$script:GenMs     = 0.0
$script:LastGen   = $null     # @{Tok; Tps}
$script:LastPrompt= $null
$script:Gpu       = $null
$script:Filtered  = $false
$script:Row       = 0
$script:W         = 100
$script:Flash     = ""
$script:FlashUntil= [datetime]::MinValue
$script:StartedAt = $null

# ---------------------------------------------------------------- helpers
function L {
    # L 'text' Color 'text' Color ...   -> one padded line at the current row
    if ($script:Row -ge [Console]::WindowHeight - 1) { return }
    [Console]::SetCursorPosition(0, $script:Row)
    $used = 0
    for ($i = 0; $i -lt $args.Count; $i += 2) {
        $t = [string]$args[$i]; $c = $args[$i + 1]
        $room = $script:W - $used
        if ($room -le 0) { break }
        if ($t.Length -gt $room) { $t = $t.Substring(0, $room) }
        Write-Host $t -NoNewline -ForegroundColor $c
        $used += $t.Length
    }
    if ($used -lt $script:W) { Write-Host (' ' * ($script:W - $used)) -NoNewline }
    $script:Row++
}

function Rule { L ($RULE * $script:W) DarkGray }

function Bar([double]$pct, [int]$len = 24) {
    $pct = [Math]::Max(0, [Math]::Min(100, $pct))
    $n = [int][Math]::Round($len * $pct / 100)
    return ($FULL * $n) + ($EMPTY * ($len - $n))
}

function PctColor([double]$p) { if ($p -lt 60) { 'Green' } elseif ($p -lt 85) { 'Yellow' } else { 'Red' } }

function Span([TimeSpan]$t) { '{0:00}:{1:00}:{2:00}' -f [int][Math]::Floor($t.TotalHours), $t.Minutes, $t.Seconds }

function Num($s) { $v = 0.0; if ([double]::TryParse(($s -replace '[^\d\.\-]', ''), [ref]$v)) { $v } else { 0.0 } }

function Set-Flash([string]$msg) { $script:Flash = $msg; $script:FlashUntil = (Get-Date).AddSeconds(3) }

# ---------------------------------------------------------------- environment probes
function Get-Gpu {
    try {
        $o = & nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv,noheader,nounits 2>$null
        if (-not $o) { return $null }
        $p = ([string]($o | Select-Object -First 1)) -split ',\s*'
        [pscustomobject]@{
            Name = $p[0]; Util = (Num $p[1]); MemUsed = (Num $p[2]); MemTotal = (Num $p[3])
            Temp = (Num $p[4]); Power = (Num $p[5])
        }
    } catch { $null }
}

function Get-LanIp {
    try {
        (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254)' -and $_.PrefixOrigin -ne 'WellKnown' } |
            Select-Object -First 1).IPAddress
    } catch { $null }
}

function Test-Health {
    try { (Invoke-WebRequest "http://127.0.0.1:$Port/health" -UseBasicParsing -TimeoutSec 1).StatusCode -eq 200 }
    catch { $false }
}

# ---------------------------------------------------------------- preflight
function Invoke-Preflight {
    Clear-Host
    Write-Host ""
    Write-Host "AKHET-Ra v.1 Local Intelligence - Preflight Loading ... " -ForegroundColor Cyan
    Write-Host ("  " + ($RULE * 40)) -ForegroundColor DarkGray
    $ok = $true
    $checks = @()

    $checks += , @("llama-server.exe", (Test-Path $script:Exe), $script:Exe)
    $checks += , @("Model file", (Test-Path $ModelPath), $ModelPath)

    $gpu = Get-Gpu
    $checks += , @("NVIDIA GPU (nvidia-smi)", ($null -ne $gpu), $(if ($gpu) { "$($gpu.Name), $([int]$gpu.MemTotal) MiB" } else { "not found - will run without GPU stats" }))

    $listener = $null
    try { $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1 } catch {}
    $who = ""
    if ($listener) { try { $who = (Get-Process -Id $listener.OwningProcess).ProcessName + " (PID $($listener.OwningProcess))" } catch { $who = "PID $($listener.OwningProcess)" } }
    $checks += , @("Port $Port free", (-not $listener), $(if ($listener) { "in use by $who" } else { "available" }))

    foreach ($c in $checks) {
        $good = $c[1]
        $isGpu = $c[0] -like 'NVIDIA*'
        $mark = if ($good) { "[ OK ]" } elseif ($isGpu) { "[WARN]" } else { "[FAIL]" }
        $col  = if ($good) { 'Green' } elseif ($isGpu) { 'Yellow' } else { 'Red' }
        Write-Host ("  " + $mark + " ") -ForegroundColor $col -NoNewline
        Write-Host ($c[0].PadRight(26)) -NoNewline
        Write-Host $c[2] -ForegroundColor DarkGray
        if (-not $good -and -not $isGpu) { $ok = $false }
    }
    Write-Host ""
    if (-not $ok) {
        Write-Host "  Fix the failed checks above and run again." -ForegroundColor Red
        return $false
    }
    Start-Sleep -Milliseconds 700
    return $true
}

# ---------------------------------------------------------------- process control
function Build-Args {
    $a = @(
        '-m', "`"$ModelPath`"", '--alias', $Alias,
        '-ngl', $GpuLayers, '-c', $ContextSize, '-t', $Threads,
        '--jinja', '--flash-attn', 'on',
        '-ctk', 'q4_0', '-ctv', 'q4_0',
        '--batch-size', 1024, '--ubatch-size', 512,
        '--parallel', 1,
        '--host', $script:BindHost, '--port', $Port
    )
    if ($ApiKey) { $a += @('--api-key', "`"$ApiKey`"") }
    return ($a -join ' ')
}

function Start-Server {
    foreach ($id in 'akhet.out', 'akhet.err') { Unregister-Event -SourceIdentifier $id -ErrorAction SilentlyContinue; Remove-Event -SourceIdentifier $id -ErrorAction SilentlyContinue }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $script:Exe
    $psi.Arguments = Build-Args
    $psi.WorkingDirectory = $LlamaDir
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.EnvironmentVariables["PATH"] = "$LlamaDir;" + $psi.EnvironmentVariables["PATH"]

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    $action = { if ($EventArgs.Data) { $Event.MessageData.Enqueue($EventArgs.Data) } }
    Register-ObjectEvent -InputObject $p -EventName OutputDataReceived -SourceIdentifier 'akhet.out' -MessageData $script:Queue -Action $action | Out-Null
    Register-ObjectEvent -InputObject $p -EventName ErrorDataReceived  -SourceIdentifier 'akhet.err' -MessageData $script:Queue -Action $action | Out-Null

    $script:Log.Clear()
    $script:Healthy = $false; $script:Busy = $false; $script:Offload = ""
    $script:Requests = 0; $script:GenTokens = 0; $script:GenMs = 0.0
    $script:LastGen = $null; $script:LastPrompt = $null

    [void]$p.Start()
    $p.BeginOutputReadLine()
    $p.BeginErrorReadLine()
    $script:Proc = $p
    $script:StartedAt = Get-Date
}

function Stop-Server {
    if ($script:Proc -and -not $script:Proc.HasExited) {
        try { & taskkill /PID $script:Proc.Id /T /F 2>&1 | Out-Null } catch { try { $script:Proc.Kill() } catch {} }
        try { [void]$script:Proc.WaitForExit(3000) } catch {}
    }
}

# ---------------------------------------------------------------- log parsing
function Add-LogLine([string]$line) {
    $script:Log.Add($line)
    if ($script:Log.Count -gt 400) { $script:Log.RemoveRange(0, 100) }

    if ($line -match 'offloaded\s+(\d+)/(\d+)\s+layers to GPU') { $script:Offload = "$($Matches[1])/$($Matches[2]) layers on GPU" }
    elseif ($line -match 'prompt eval time\s*=\s*([\d\.]+)\s*ms\s*/\s*(\d+)\s*tokens.*?([\d\.]+)\s*tokens per second') {
        $script:LastPrompt = @{ Tok = [int]$Matches[2]; Tps = [double]$Matches[3] }
    }
    elseif ($line -match '(?<!prompt )eval time\s*=\s*([\d\.]+)\s*ms\s*/\s*(\d+)\s*(?:tokens|runs).*?([\d\.]+)\s*tokens per second') {
        $script:Requests++
        $script:GenMs += [double]$Matches[1]; $script:GenTokens += [int]$Matches[2]
        $script:LastGen = @{ Tok = [int]$Matches[2]; Tps = [double]$Matches[3] }
    }
    elseif ($line -match 'all slots are idle|release:') { $script:Busy = $false }
    elseif ($line -match 'launch_slot_|processing task|new prompt') { $script:Busy = $true }
}

function Get-LogColor([string]$l) {
    if ($l -match '(?i)\b(error|failed|fatal|out of memory|cuda error)\b') { return 'Red' }
    if ($l -match '(?i)\bwarn') { return 'Yellow' }
    if ($l -match 'eval time|listening|loaded|offloaded') { return 'Cyan' }
    return 'DarkGray'
}

$script:NoiseFilter = '(?i)error|warn|fail|listening|loaded|offload|CUDA|eval time|launch_slot|release|idle|ready'

# ---------------------------------------------------------------- rendering
function Render {
    $script:W = [Math]::Min([Console]::WindowWidth - 1, 110)
    $script:Row = 0
    $hgt = [Console]::WindowHeight

    $exited = $script:Proc -and $script:Proc.HasExited
    if ($exited) {
        $state = if ($script:Proc.ExitCode -eq 0) { 'STOPPED' } else { "CRASHED ($($script:Proc.ExitCode))" }
        $sc = if ($script:Proc.ExitCode -eq 0) { 'DarkGray' } else { 'Red' }
    }
    elseif ($script:Healthy) {
        if ($script:Busy) { $state = 'GENERATING'; $sc = 'Cyan' } else { $state = 'READY'; $sc = 'Green' }
    }
    else { $state = 'LOADING'; $sc = 'Yellow' }

    # --- header
    $title = "  AKHET-Ra v.1 Local Intelligence -  llama.cpp server"
    $badge = "$DOT $state  "
    $pad = [Math]::Max(1, $script:W - $title.Length - $badge.Length)
    L $title White (' ' * $pad) White $badge $sc
    Rule

    # --- config
    $size = ""; try { $size = " ({0:N1} GB)" -f ((Get-Item $ModelPath).Length / 1GB) } catch {}
    L "  Model   " DarkGray ([IO.Path]::GetFileName($ModelPath) + $size) White
    $cfg = "ctx $ContextSize  |  ngl $GpuLayers  |  threads $Threads  |  KV q4_0  |  flash-attn"
    if ($script:Offload) { $cfg += "  |  $($script:Offload)" }
    L "  Config  " DarkGray $cfg Gray
    $up = if ($script:StartedAt) { Span ((Get-Date) - $script:StartedAt) } else { "--" }
    $pid_ = if ($script:Proc) { $script:Proc.Id } else { "--" }
    L "  Uptime  " DarkGray $up White "     PID " DarkGray "$pid_" White

    $local = "http://127.0.0.1:$Port"
    L "  Local   " DarkGray $local Cyan "     OpenAI API: " DarkGray "$local/v1" Cyan
    if (-not $LocalOnly) {
        $lan = $script:LanIp
        $warn = if ($ApiKey) { "  (API key required)" } else { "  (no API key - open to LAN)" }
        $wc = if ($ApiKey) { 'Green' } else { 'Yellow' }
        if ($lan) { L "  LAN     " DarkGray "http://${lan}:$Port" Cyan $warn $wc }
    }
    Rule

    # --- GPU
    $g = $script:Gpu
    if ($g) {
        $vp = if ($g.MemTotal -gt 0) { 100 * $g.MemUsed / $g.MemTotal } else { 0 }
        L "  GPU   " DarkGray $g.Name White ("   {0:N0}C  {1:N0}W" -f $g.Temp, $g.Power) Gray
        L "  Util  " DarkGray (Bar $g.Util) (PctColor $g.Util) (" {0,3:N0}%" -f $g.Util) White
        L "  VRAM  " DarkGray (Bar $vp) (PctColor $vp) (" {0:N1} / {1:N1} GB" -f ($g.MemUsed / 1024), ($g.MemTotal / 1024)) White
    } else {
        L "  GPU   " DarkGray "nvidia-smi unavailable" DarkGray
    }
    Rule

    # --- throughput
    $lp = if ($script:LastPrompt) { "{0} tok @ {1:N0} t/s" -f $script:LastPrompt.Tok, $script:LastPrompt.Tps } else { "--" }
    $lg = if ($script:LastGen)    { "{0} tok @ {1:N1} t/s" -f $script:LastGen.Tok, $script:LastGen.Tps } else { "--" }
    $avg = if ($script:GenMs -gt 0) { "{0:N1} t/s" -f (1000 * $script:GenTokens / $script:GenMs) } else { "--" }
    L "  Requests " DarkGray "$($script:Requests)" White "   Prompt " DarkGray $lp Gray "   Gen " DarkGray $lg Green "   Avg " DarkGray $avg Green
    Rule

    # --- log pane
    $mode = if ($script:Filtered) { "filtered" } else { "all" }
    L "  LOG ($mode)" DarkGray
    $footerRows = 2
    $room = $hgt - 1 - $script:Row - $footerRows
    if ($room -lt 1) { $room = 1 }
    $src = if ($script:Filtered) { @($script:Log | Where-Object { $_ -match $script:NoiseFilter }) } else { $script:Log.ToArray() }
    $start = [Math]::Max(0, $src.Count - $room)
    $shown = 0
    for ($i = $start; $i -lt $src.Count; $i++) {
        $line = ($src[$i] -replace "`t", ' ')
        L "  $line" (Get-LogColor $line)
        $shown++
    }
    while ($shown -lt $room) { L "" Gray; $shown++ }

    # --- footer
    $script:Row = $hgt - 3
    Rule
    if ((Get-Date) -lt $script:FlashUntil) { L "  $($script:Flash)" Yellow }
    else { L "  [Q]uit  [R]estart  [O]pen UI  [C]opy URL  [L]og filter" DarkGray }
}

# ---------------------------------------------------------------- main
if (-not (Invoke-Preflight)) { exit 1 }

$script:LanIp = if ($LocalOnly) { $null } else { Get-LanIp }
$oldCtrl = [Console]::TreatControlCAsInput
$oldEnc  = [Console]::OutputEncoding
$lastSize = ""
$lastRender = [datetime]::MinValue
$lastProbe  = [datetime]::MinValue

try {
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    [Console]::TreatControlCAsInput = $true
    [Console]::CursorVisible = $false
    Clear-Host
    Start-Server

    while ($true) {
        $dirty = $false

        # drain log queue
        $line = $null
        while ($script:Queue.TryDequeue([ref]$line)) { Add-LogLine $line; $dirty = $true }

        # probes every 2s
        if (((Get-Date) - $lastProbe).TotalSeconds -ge 2) {
            $lastProbe = Get-Date
            if ($script:Proc -and -not $script:Proc.HasExited) { $script:Healthy = Test-Health } else { $script:Healthy = $false }
            $script:Gpu = Get-Gpu
            $dirty = $true
        }

        # keys
        while ([Console]::KeyAvailable) {
            $k = [Console]::ReadKey($true)
            $ctrlC = ($k.Key -eq 'C') -and (($k.Modifiers -band [ConsoleModifiers]::Control) -ne 0)
            if ($ctrlC -or $k.Key -eq 'Q') { return }
            switch ($k.Key) {
                'R' { Set-Flash "Restarting..."; Stop-Server; Start-Server }
                'O' { Start-Process "http://127.0.0.1:$Port"; Set-Flash "Opened web UI in browser" }
                'C' { Set-Clipboard "http://127.0.0.1:$Port/v1"; Set-Flash "Copied http://127.0.0.1:$Port/v1" }
                'L' { $script:Filtered = -not $script:Filtered }
            }
            $dirty = $true
        }

        # resize handling
        $size = "$([Console]::WindowWidth)x$([Console]::WindowHeight)"
        if ($size -ne $lastSize) { Clear-Host; $lastSize = $size; $dirty = $true }

        if ($dirty -or ((Get-Date) - $lastRender).TotalMilliseconds -ge 1000) {
            Render
            $lastRender = Get-Date
        }
        Start-Sleep -Milliseconds 120
    }
}
finally {
    Stop-Server
    foreach ($id in 'akhet.out', 'akhet.err') { Unregister-Event -SourceIdentifier $id -ErrorAction SilentlyContinue }
    [Console]::CursorVisible = $true
    [Console]::TreatControlCAsInput = $oldCtrl
    try { [Console]::OutputEncoding = $oldEnc } catch {}
    Clear-Host
    Write-Host "Akhet-1 server stopped." -ForegroundColor Green
}
