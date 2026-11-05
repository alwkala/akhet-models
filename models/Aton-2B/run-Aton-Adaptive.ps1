<#
.SYNOPSIS
  AKHET-Aton v3.0 Adaptive Multimodal Engine & Live TUI Dashboard for llama-server (PS 5.1+ / PS 7).

.DESCRIPTION
  Standardized, hardware-aware launcher for Akhet-Aton-2B Multimodal Vision-Language Model on 4GB - 12GB+ VRAM GPUs.
  - Full Multimodal Vision Support: Automatically couples the language weights (Aton-2B-Q4_K_M.gguf) with
    the CLIP vision encoder projector (Aton-2B-F16-mmproj.gguf) via --mmproj.
  - Default Mode (APEX-1): 100% of context & bandwidth dedicated to 1 primary agent (-np 1).
    Multiple agents can still operate sequentially at zero speed loss via Prefix Cache Reuse (--cache-reuse).
  - Hybrid Mode (DUO-2): 2 concurrent slots (-np 2) for simultaneous vision-language execution.
  - Swarm Mode (SWARM-4): 4 concurrent slots (-np 4) when VRAM permits.
  - Auto Hardware Calibration: Detects GPU VRAM (4GB/6GB/8GB/12GB+) to prevent OOM
    and pick optimal Context Size, KV Cache quantization (q4_0/q8_0), and GPU layer offload.
  - Hotkeys:
      [M] Cycle Engine Mode: APEX-1 (1 Slot Full Power) -> DUO-2 (2 Slots Hybrid) -> SWARM-4 (4 Slots)
      [X] Cycle Context Size: 8K -> 16K -> 32K -> 64K
      [K] Toggle KV Quantization: q4_0 <-> q8_0
      [N] Toggle Network: LocalOnly (127.0.0.1) <-> LAN Open (0.0.0.0)
      [R] Restart Server | [O] Open Web UI | [C] Copy API URL | [L] Toggle Log Filter | [Q] Quit
#>
[CmdletBinding()]
param(
    [string]$LlamaDir      = "A:\llama-cpp",
    [string]$ModelPath     = "",
    [string]$MmprojPath    = "",
    [string]$Alias         = "Akhet-Aton-2B",
    [ValidateSet("Auto", "Apex1", "Duo2", "Swarm4")]
    [string]$EngineMode    = "Apex1",
    [int]$GpuLayers        = 99,
    [int]$ContextSize      = 0,
    [int]$CacheReuse       = 256,
    [string]$KvCacheType   = "auto",
    [int]$Threads          = 0,
    [int]$Port             = 8080,
    [string]$ApiKey        = "",
    [switch]$LocalOnly
)

Set-StrictMode -Off;
$ErrorActionPreference = 'Stop';

# ---------------------------------------------------------------- dynamic path resolution
function Resolve-AtonPath([string]$given, [string]$fileName, [string[]]$fallbacks) {
    if ($given -and (Test-Path $given)) { return (Resolve-Path $given).Path }
    foreach ($cand in $fallbacks) {
        if (Test-Path $cand) { return (Resolve-Path $cand).Path }
    }
    return $given
}

$ModelPath = Resolve-AtonPath $ModelPath "Aton-2B-Q4_K_M.gguf" @(
    (Join-Path $PSScriptRoot "Aton-2B-Q4_K_M.gguf"),
    (Join-Path $PSScriptRoot "Aton-2B\Aton-2B-Q4_K_M.gguf"),
    "A:\Alwkala-Ai-Lab\Aton-2B\Aton-2B-Q4_K_M.gguf",
    "A:\.lmstudio\alwkala\Aton-2B\Aton-2B-Q4_K_M.gguf"
);

$MmprojPath = Resolve-AtonPath $MmprojPath "Aton-2B-F16-mmproj.gguf" @(
    (Join-Path $PSScriptRoot "Aton-2B-F16-mmproj.gguf"),
    (Join-Path $PSScriptRoot "Aton-2B\Aton-2B-F16-mmproj.gguf"),
    "A:\Alwkala-Ai-Lab\Aton-2B\Aton-2B-F16-mmproj.gguf",
    "A:\.lmstudio\alwkala\Aton-2B\Aton-2B-F16-mmproj.gguf"
);
    "A:\Alwkala-Ai-Lab\Aton-2B\Aton-2B-F16-mmproj.gguf"
);

# ---------------------------------------------------------------- glyphs (ASCII-safe)
$FULL  = [string][char]0x2588;
$EMPTY = [string][char]0x2591;
$RULE  = [string][char]0x2500;
$DOT   = [string][char]0x25CF;

# ---------------------------------------------------------------- state
$script:Exe           = Join-Path $LlamaDir "llama-server.exe";
$script:IsLocal       = [bool]$LocalOnly;
$script:BindHost      = if ($script:IsLocal) { "127.0.0.1" } else { "0.0.0.0" };
$script:LanIp         = $null;
$script:Proc          = $null;
$script:Queue         = [System.Collections.Concurrent.ConcurrentQueue[string]]::new();
$script:Log           = New-Object System.Collections.Generic.List[string];
$script:Healthy       = $false;
$script:Busy          = $false;
$script:Offload       = "";
$script:Requests      = 0;
$script:GenTokens     = 0;
$script:GenMs         = 0.0;
$script:LastGen       = $null;
$script:LastPrompt    = $null;
$script:Gpu           = $null;
$script:Filtered      = $false;
$script:Row           = 0;
$script:W             = 100;
$script:Flash         = "";
$script:FlashUntil    = [datetime]::MinValue;
$script:StartedAt     = $null;
$script:SlotStats     = @{};
$script:ParallelSlots = 1;
$script:ProfileNote   = "";
$script:ModelGb       = 0.0;
$script:MmprojGb      = 0.0;

# ---------------------------------------------------------------- helpers
function L {
    if ($script:Row -ge [Console]::WindowHeight - 1) { return };
    [Console]::SetCursorPosition(0, $script:Row);
    $used = 0;
    for ($i = 0; $i -lt $args.Count; $i += 2) {
        $t = [string]$args[$i]; $c = $args[$i + 1];
        $room = $script:W - $used;
        if ($room -le 0) { break };
        if ($t.Length -gt $room) { $t = $t.Substring(0, $room) };
        Write-Host $t -NoNewline -ForegroundColor $c;
        $used += $t.Length;
    }
    if ($used -lt $script:W) { Write-Host (' ' * ($script:W - $used)) -NoNewline };
    $script:Row++;
}

function Rule { L ($RULE * $script:W) DarkGray }

function Bar([double]$pct, [int]$len = 20) {
    $pct = [Math]::Max(0, [Math]::Min(100, $pct));
    $n = [int][Math]::Round($len * $pct / 100);
    return ($FULL * $n) + ($EMPTY * ($len - $n));
}

function PctColor([double]$p) { if ($p -lt 65) { 'Green' } elseif ($p -lt 85) { 'Yellow' } else { 'Red' } }

function Span([TimeSpan]$t) { '{0:00}:{1:00}:{2:00}' -f [int][Math]::Floor($t.TotalHours), $t.Minutes, $t.Seconds }

function Num($s) {
    $v = 0.0;
    $clean = ($s -replace '[^\d\.\-]', '');
    if ([double]::TryParse($clean, [Globalization.NumberStyles]::Any, [Globalization.CultureInfo]::InvariantCulture, [ref]$v)) { $v } else { 0.0 }
}

function Set-Flash([string]$msg) { $script:Flash = $msg; $script:FlashUntil = (Get-Date).AddSeconds(3.5) }

# ---------------------------------------------------------------- hardware calibration
function Get-Gpu {
    try {
        $o = & nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv,noheader,nounits 2>$null;
        if (-not $o) { return $null };
        $p = ([string]($o | Select-Object -First 1)) -split ',\s*';
        [pscustomobject]@{
            Name = $p[0]; Util = (Num $p[1]); MemUsed = (Num $p[2]); MemTotal = (Num $p[3]);
            Temp = (Num $p[4]); Power = (Num $p[5])
        }
    } catch { $null }
}

function Invoke-HardwareCalibration {
    if ($script:Threads -le 0) {
        try {
            $cores = (Get-CimInstance Win32_Processor -ErrorAction Stop | Measure-Object -Property NumberOfCores -Sum).Sum;
            $script:Threads = if ($cores -gt 0) { [Math]::Min([int]$cores, 12) } else { 8 };
        } catch { $script:Threads = 8 }
    }

    $script:ModelGb = 1.31;
    if (Test-Path $ModelPath) {
        try { $script:ModelGb = [Math]::Round(((Get-Item $ModelPath).Length / 1GB), 2) } catch {}
    }
    $script:MmprojGb = 0.67;
    if (Test-Path $MmprojPath) {
        try { $script:MmprojGb = [Math]::Round(((Get-Item $MmprojPath).Length / 1GB), 2) } catch {}
    }

    $totalModelGb = $script:ModelGb + $script:MmprojGb;

    $g = Get-Gpu;
    $vramGb = if ($g -and $g.MemTotal -gt 0) { [Math]::Round($g.MemTotal / 1024.0, 1) } else { 6.0 };
    $freeVramBudget = $vramGb - $totalModelGb - 0.55;

    switch ($EngineMode) {
        "Apex1"  { $script:ParallelSlots = 1 }
        "Duo2"   { $script:ParallelSlots = 2 }
        "Swarm4" { $script:ParallelSlots = 4 }
        "Auto"   {
            if ($vramGb -le 6.5) { $script:ParallelSlots = 1 }
            else { $script:ParallelSlots = 2 }
        }
    }

    if ($KvCacheType -eq "auto") {
        $script:KvCacheType = if ($freeVramBudget -ge 3.0) { "q8_0" } else { "q4_0" };
    }

    if ($ContextSize -le 0) {
        if ($freeVramBudget -lt 0.8) {
            $script:ContextSize = 8192;
            $script:KvCacheType = "q4_0";
        }
        elseif ($freeVramBudget -lt 1.8) {
            $script:ContextSize = 16384;
            $script:KvCacheType = "q4_0";
        }
        elseif ($freeVramBudget -lt 3.5) {
            $script:ContextSize = 32768;
        }
        else {
            $script:ContextSize = 65536;
        }
    }

    $tierName = if ($vramGb -le 4.5) { "4GB Entry" } elseif ($vramGb -le 6.5) { "6GB Mid" } elseif ($vramGb -le 8.5) { "8GB High" } else { "12GB+ Pro" };
    $script:ProfileNote = "$tierName GPU | Model ${totalModelGb}GB (LLM+CLIP) | Free Budget ~$([Math]::Max(0.1, [Math]::Round($freeVramBudget, 1)))GB";
}

function Reset-Slots {
    $script:SlotStats = @{};
    for ($i = 0; $i -lt $script:ParallelSlots; $i++) {
        $script:SlotStats[$i] = @{ State = 'IDLE'; Task = 0; Decoded = 0; Tps = 0.0; Updated = [datetime]::MinValue };
    }
}

function Get-LanIp {
    try {
        $cfg = Get-NetIPConfiguration -ErrorAction Stop |
            Where-Object { $null -ne $_.IPv4DefaultGateway -and $_.InterfaceAlias -notmatch 'WSL|vEthernet|Docker|VMware|VirtualBox|Loopback' } |
            Select-Object -First 1;
        if ($cfg -and $cfg.IPv4Address) { return $cfg.IPv4Address[0].IPAddress };

        (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254)' -and $_.InterfaceAlias -notmatch 'WSL|vEthernet|Docker' } |
            Select-Object -First 1).IPAddress
    } catch { $null }
}

function Test-PortQuick([int]$p) {
    $c = New-Object System.Net.Sockets.TcpClient;
    try {
        $iar = $c.BeginConnect("127.0.0.1", $p, $null, $null);
        if (-not $iar.AsyncWaitHandle.WaitOne(120, $false)) { return $false };
        $c.EndConnect($iar);
        return $true;
    } catch { return $false }
    finally { $c.Close() }
}

function Test-Health {
    if (-not (Test-PortQuick $Port)) { return $false };
    try { (Invoke-WebRequest "http://127.0.0.1:$Port/health" -UseBasicParsing -TimeoutSec 1).StatusCode -eq 200 }
    catch { $false }
}

function Update-SlotsFromApi {
    if (-not $script:Healthy) { return };
    try {
        $headers = @{};
        if ($ApiKey) { $headers["Authorization"] = "Bearer $ApiKey" };
        $res = Invoke-RestMethod "http://127.0.0.1:$Port/slots" -Headers $headers -TimeoutSec 1 -ErrorAction Stop;
        $anyBusy = $false;
        foreach ($s in $res) {
            $id = [int]$s.id;
            if (-not $script:SlotStats.ContainsKey($id)) {
                $script:SlotStats[$id] = @{ State = 'IDLE'; Task = 0; Decoded = 0; Tps = 0.0; Updated = [datetime]::MinValue };
            }
            $isBusy = ($s.is_processing -eq $true) -or ($s.state -ne 0 -and $null -ne $s.state);
            if ($isBusy) {
                $anyBusy = $true;
                $script:SlotStats[$id].State = 'RUN';
            } else {
                if (((Get-Date) - $script:SlotStats[$id].Updated).TotalSeconds -gt 1.5) {
                    $script:SlotStats[$id].State = 'IDLE';
                    $script:SlotStats[$id].Tps   = 0.0;
                }
            }
        }
        $script:Busy = $anyBusy;
    } catch {}
}

# ---------------------------------------------------------------- preflight
function Invoke-Preflight {
    Invoke-HardwareCalibration;
    Reset-Slots;
    Clear-Host;
    Write-Host "";
    Write-Host "AKHET-Aton v3.0 Adaptive Multimodal Engine (Vision+Text) - Preflight..." -ForegroundColor Cyan;
    Write-Host ("  " + ($RULE * 72)) -ForegroundColor DarkGray;
    $ok = $true;
    $checks = @();

    $checks += , @("llama-server.exe", (Test-Path $script:Exe), $script:Exe, $true);
    $checks += , @("Model File", (Test-Path $ModelPath), "$ModelPath ($($script:ModelGb) GB)", $true);
    $checks += , @("Vision mmproj", (Test-Path $MmprojPath), "$MmprojPath ($($script:MmprojGb) GB)", $true);

    $gpu = Get-Gpu;
    $checks += , @("GPU & VRAM Tier", ($null -ne $gpu), $(if ($gpu) { "$($gpu.Name) ($([int]$gpu.MemTotal) MiB) -> $($script:ProfileNote)" } else { "CPU/Fallback mode" }), $false);

    $listener = $null;
    try { $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1 } catch {};
    $who = "";
    if ($listener) { try { $who = (Get-Process -Id $listener.OwningProcess).ProcessName + " (PID $($listener.OwningProcess))" } catch { $who = "PID $($listener.OwningProcess)" } };
    $checks += , @("Port $Port Status", (-not $listener), $(if ($listener) { "BUSY by $who" } else { "Available" }), $true);

    $perSlotCtx = [int][Math]::Floor($script:ContextSize / [Math]::Max(1, $script:ParallelSlots));
    $modeDesc = if ($script:ParallelSlots -eq 1) { "APEX-1 (Full Multimodal Power: $perSlotCtx ctx + Cache Reuse)" }
                elseif ($script:ParallelSlots -eq 2) { "DUO-2 Hybrid (2 Parallel Slots x $perSlotCtx ctx/slot)" }
                else { "SWARM-$($script:ParallelSlots) ($($script:ParallelSlots) Parallel Slots x $perSlotCtx ctx/slot)" };
    $checks += , @("Engine Topology", ($perSlotCtx -ge 2048), $modeDesc, $true);

    foreach ($c in $checks) {
        $good    = $c[1];
        $isFatal = $c[3];
        $mark = if ($good) { "[ OK ]" } elseif (-not $isFatal) { "[WARN]" } else { "[FAIL]" };
        $col  = if ($good) { 'Green' } elseif (-not $isFatal) { 'Yellow' } else { 'Red' };
        Write-Host ("  " + $mark + " ") -ForegroundColor $col -NoNewline;
        Write-Host ($c[0].PadRight(22)) -NoNewline;
        Write-Host $c[2] -ForegroundColor DarkGray;
        if (-not $good -and $isFatal) { $ok = $false };
    }
    Write-Host "";
    if (-not $ok) {
        Write-Host "  Fix the failed checks above and run again." -ForegroundColor Red;
        return $false;
    }
    Start-Sleep -Milliseconds 700;
    return $true;
}

# ---------------------------------------------------------------- process control
function Build-Args {
    $script:BindHost = if ($script:IsLocal) { "127.0.0.1" } else { "0.0.0.0" };
    $script:LanIp    = if ($script:IsLocal) { $null } else { Get-LanIp };

    $uBatch = if ($script:ParallelSlots -eq 1) { 1024 } else { 512 };

    $a = @(
        '-m', "`"$ModelPath`"",
        '--mmproj', "`"$MmprojPath`"",
        '--image-min-tokens', 1024,
        '--alias', $Alias,
        '-ngl', $GpuLayers, '-c', $script:ContextSize, '-t', $script:Threads,
        '--jinja', '--flash-attn', 'on',
        '-ctk', $script:KvCacheType, '-ctv', $script:KvCacheType,
        '--batch-size', 2048, '--ubatch-size', $uBatch,
        '--parallel', $script:ParallelSlots,
        '--cont-batching',
        '--cache-reuse', $CacheReuse,
        '--slots', '--metrics',
        '--host', $script:BindHost, '--port', $Port
    );
    if ($ApiKey) { $a += @('--api-key', "`"$ApiKey`"") };
    return ($a -join ' ');
}

function Start-Server {
    foreach ($id in 'aton.out', 'aton.err') {
        Unregister-Event -SourceIdentifier $id -ErrorAction SilentlyContinue;
        Remove-Event -SourceIdentifier $id -ErrorAction SilentlyContinue;
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo;
    $psi.FileName = $script:Exe;
    $psi.Arguments = Build-Args;
    $psi.WorkingDirectory = $LlamaDir;
    $psi.UseShellExecute = $false;
    $psi.CreateNoWindow = $true;
    $psi.RedirectStandardOutput = $true;
    $psi.RedirectStandardError = $true;
    $psi.EnvironmentVariables["PATH"] = "$LlamaDir;" + $psi.EnvironmentVariables["PATH"];

    $p = New-Object System.Diagnostics.Process;
    $p.StartInfo = $psi;
    $action = { if ($EventArgs.Data) { $Event.MessageData.Enqueue($EventArgs.Data) } };
    Register-ObjectEvent -InputObject $p -EventName OutputDataReceived -SourceIdentifier 'aton.out' -MessageData $script:Queue -Action $action | Out-Null;
    Register-ObjectEvent -InputObject $p -EventName ErrorDataReceived  -SourceIdentifier 'aton.err' -MessageData $script:Queue -Action $action | Out-Null;

    $script:Log.Clear();
    $script:Healthy = $false; $script:Busy = $false; $script:Offload = "";
    $script:Requests = 0; $script:GenTokens = 0; $script:GenMs = 0.0;
    $script:LastGen = $null; $script:LastPrompt = $null;
    Reset-Slots;

    [void]$p.Start();
    $p.BeginOutputReadLine();
    $p.BeginErrorReadLine();
    $script:Proc = $p;
    $script:StartedAt = Get-Date;
}

function Stop-Server {
    if ($script:Proc -and -not $script:Proc.HasExited) {
        try { & taskkill /PID $script:Proc.Id /T /F 2>&1 | Out-Null } catch { try { $script:Proc.Kill() } catch {} };
        try { [void]$script:Proc.WaitForExit(3000) } catch {};
    }
}

# ---------------------------------------------------------------- log parsing
function Add-LogLine([string]$line) {
    $script:Log.Add($line);
    if ($script:Log.Count -gt 400) { $script:Log.RemoveRange(0, 100) };

    if ($line -match 'offloaded\s+(\d+)/(\d+)\s+layers to GPU') {
        $script:Offload = "$($Matches[1])/$($Matches[2]) layers on GPU";
    }
    elseif ($line -match 'slot\s+print_timing:\s+id\s+(\d+)\s+\|\s+task\s+(\d+)\s+\|\s+n_decoded\s*=\s*(\d+),\s*tg\s*=\s*([\d\.]+)\s*t/s') {
        $sid  = [int]$Matches[1];
        $task = [int]$Matches[2];
        $dec  = [int]$Matches[3];
        $tps  = Num $Matches[4];
        $script:SlotStats[$sid] = @{ State = 'RUN'; Task = $task; Decoded = $dec; Tps = $tps; Updated = (Get-Date) };
        $script:LastGen = @{ Tok = $dec; Tps = $tps };
        $script:GenTokens += $dec;
        $script:Requests++;
    }
    elseif ($line -match 'prompt eval time\s*=\s*([\d\.]+)\s*ms\s*/\s*(\d+)\s*tokens\s*\(\s*([\d\.]+)\s*t/s\)') {
        $script:LastPrompt = @{ Tok = [int]$Matches[2]; Tps = Num $Matches[3] };
    }
    elseif ($line -match 'all slots are idle|release_slot') {
        $script:Busy = $false;
        foreach ($k in @($script:SlotStats.Keys)) {
            $script:SlotStats[$k].State = 'IDLE';
            $script:SlotStats[$k].Tps   = 0.0;
        }
    }
    elseif ($line -match 'launch_slot_|processing task|new prompt|Chat format:|clip|image') {
        $script:Busy = $true;
    }
}

function Get-LogColor([string]$l) {
    if ($l -match '(?i)\b(error|failed|fatal|out of memory|cuda error)\b') { return 'Red' };
    if ($l -match '(?i)\bwarn') { return 'Yellow' };
    if ($l -match 'print_timing') { return 'Green' };
    if ($l -match 'eval time|listening|loaded|offloaded|Chat format|clip|image') { return 'Cyan' };
    return 'DarkGray';
}

$script:NoiseFilter = '(?i)error|warn|fail|listening|loaded|offload|CUDA|eval time|print_timing|launch_slot|release|idle|ready|Chat format|clip';

# ---------------------------------------------------------------- rendering
function Render {
    $script:W = [Math]::Min([Console]::WindowWidth - 1, 116);
    $script:Row = 0;
    $hgt = [Console]::WindowHeight;

    $activeCount = 0;
    $swarmTps    = 0.0;
    foreach ($k in @($script:SlotStats.Keys)) {
        $st = $script:SlotStats[$k];
        if ($st.State -eq 'RUN' -and ((Get-Date) - $st.Updated).TotalSeconds -gt 4.0) {
            $st.State = 'IDLE'; $st.Tps = 0.0;
        }
        if ($st.State -eq 'RUN') { $activeCount++; $swarmTps += $st.Tps };
    }
    if ($activeCount -gt 0) { $script:Busy = $true };

    $exited = $script:Proc -and $script:Proc.HasExited;
    if ($exited) {
        $state = if ($script:Proc.ExitCode -eq 0) { 'STOPPED' } else { "CRASHED ($($script:Proc.ExitCode))" };
        $sc = if ($script:Proc.ExitCode -eq 0) { 'DarkGray' } else { 'Red' };
    }
    elseif ($script:Healthy) {
        if ($script:Busy) { $state = "PROCESSING ($activeCount/$($script:ParallelSlots) ACTIVE)"; $sc = 'Cyan' }
        else { $state = 'READY'; $sc = 'Green' };
    }
    else { $state = 'LOADING'; $sc = 'Yellow' };

    # --- header
    $modeTag = if ($script:ParallelSlots -eq 1) { "APEX-1: FULL POWER" }
               elseif ($script:ParallelSlots -eq 2) { "DUO-2: HYBRID" }
               else { "SWARM-4: PARALLEL" };
    $netTag  = if ($script:IsLocal) { "LOCAL-ONLY" } else { "LAN-OPEN" };
    $title   = "  AKHET-ATON v3.0 [$modeTag | $netTag] - Adaptive Multimodal Engine";
    $badge   = "$DOT $state  ";
    $pad     = [Math]::Max(1, $script:W - $title.Length - $badge.Length);
    L $title White (' ' * $pad) White $badge $sc;
    Rule;

    # --- model & hardware profile
    $perSlot = [int][Math]::Floor($script:ContextSize / [Math]::Max(1, $script:ParallelSlots));
    L "  Model   " DarkGray ([IO.Path]::GetFileName($ModelPath) + " ($($script:ModelGb) GB) + CLIP ($($script:MmprojGb) GB)") White "   Profile: " DarkGray $script:ProfileNote Cyan;
    $cfg = "ctx $($script:ContextSize) ($perSlot/agent)  |  slots $($script:ParallelSlots)  |  KV $($script:KvCacheType)  |  reuse $CacheReuse  |  threads $($script:Threads)";
    if ($script:Offload) { $cfg += "  |  $($script:Offload)" };
    L "  Engine  " DarkGray $cfg Gray;

    $up   = if ($script:StartedAt) { Span ((Get-Date) - $script:StartedAt) } else { "--" };
    $pid_ = if ($script:Proc) { $script:Proc.Id } else { "--" };
    $localUrl = "http://127.0.0.1:$Port/v1";
    L "  Uptime  " DarkGray $up White "   PID " DarkGray "$pid_" White "   Local Endpoint " DarkGray $localUrl Cyan;

    if ($script:IsLocal) {
        L "  Network " DarkGray "Isolated (127.0.0.1 only)" DarkYellow "   [Press N to open LAN]" Gray;
    } else {
        $lanUrl = if ($script:LanIp) { "http://$($script:LanIp):$Port/v1" } else { "http://0.0.0.0:$Port/v1" };
        $secMsg = if ($ApiKey) { " (API Key Active)" } else { " (Open on LAN)" };
        $secCol = if ($ApiKey) { 'Green' } else { 'Yellow' };
        L "  Network " DarkGray "LAN Active -> " Gray $lanUrl Cyan $secMsg $secCol "   [Press N for LocalOnly]" Gray;
    }
    Rule;

    # --- GPU
    $g = $script:Gpu;
    if ($g) {
        $vp = if ($g.MemTotal -gt 0) { 100 * $g.MemUsed / $g.MemTotal } else { 0 };
        L "  GPU     " DarkGray $g.Name White ("   {0:N0}C  {1:N0}W" -f $g.Temp, $g.Power) Gray;
        L "  Util    " DarkGray (Bar $g.Util) (PctColor $g.Util) (" {0,3:N0}%" -f $g.Util) White "   VRAM " DarkGray (Bar $vp) (PctColor $vp) (" {0:N1}/{1:N1} GB ({2:N0}%)" -f ($g.MemUsed / 1024), ($g.MemTotal / 1024), $vp) White;
    } else {
        L "  GPU     " DarkGray "nvidia-smi unavailable" DarkGray;
    }
    Rule;

    # --- Live Slots Bar & Throughput
    $slotArgs = @("  Slots   ", 'DarkGray');
    for ($i = 0; $i -lt $script:ParallelSlots; $i++) {
        $st = $script:SlotStats[$i];
        if ($st -and $st.State -eq 'RUN') {
            $slotArgs += @("[#$i`: {0:N1}t/s ({1} tok)] " -f $st.Tps, $st.Decoded), 'Cyan';
        } else {
            $slotArgs += @("[#$i`: IDLE ($perSlot ctx)] "), 'Green';
        }
    }
    if ($script:ParallelSlots -eq 1) {
        $slotArgs += @(" (100% Dedicated Multimodal Context + Fast Agent Queue)"), 'DarkGray';
    }
    L @slotArgs;

    $lp = if ($script:LastPrompt) { "{0} tok @ {1:N0} t/s" -f $script:LastPrompt.Tok, $script:LastPrompt.Tps } else { "--" };
    $lg = if ($script:LastGen)    { "{0} tok @ {1:N1} t/s" -f $script:LastGen.Tok, $script:LastGen.Tps } else { "--" };
    $sw = if ($swarmTps -gt 0)    { "{0:N1} t/s" -f $swarmTps } else { "--" };
    L "  Metrics " DarkGray "Tasks: " Gray "$($script:Requests)" White "  |  Speed: " Gray $lg Green "  |  Combined: " Gray $sw Cyan "  |  Prompt Eval: " Gray $lp Gray;
    Rule;

    # --- log pane
    $mode = if ($script:Filtered) { "filtered" } else { "all" };
    L "  LOG ($mode)" DarkGray;
    $footerRows = 2;
    $room = $hgt - 1 - $script:Row - $footerRows;
    if ($room -lt 1) { $room = 1 };
    $src = if ($script:Filtered) { @($script:Log | Where-Object { $_ -match $script:NoiseFilter }) } else { $script:Log.ToArray() };
    $start = [Math]::Max(0, $src.Count - $room);
    $shown = 0;
    for ($i = $start; $i -lt $src.Count; $i++) {
        $line = $src[$i];
        if ($line.Length -gt ($script:W - 4)) { $line = $line.Substring(0, $script:W - 4) };
        L "  $line" (Get-LogColor $line);
        $shown++;
    }
    while ($shown -lt $room) { L "" Gray; $shown++ };

    # --- footer
    $script:Row = $hgt - 3;
    Rule;
    if ((Get-Date) -lt $script:FlashUntil) { L "  $($script:Flash)" Yellow }
    else {
        $netBtn = if ($script:IsLocal) { "[N]et:Local" } else { "[N]et:LAN" };
        L "  [M]ode($($script:ParallelSlots)x)  [X]Ctx($([int]($script:ContextSize/1024))K)  [K]V($($script:KvCacheType))  $netBtn  [R]estart  [O]pen  [C]opy  [L]og  [Q]uit" DarkGray;
    }
}

# ---------------------------------------------------------------- main
if (-not (Invoke-Preflight)) { exit 1 };

$oldCtrl    = [Console]::TreatControlCAsInput;
$oldEnc     = [Console]::OutputEncoding;
$lastSize   = "";
$lastRender = [datetime]::MinValue;
$lastProbe  = [datetime]::MinValue;

try {
    [Console]::OutputEncoding = [Text.Encoding]::UTF8;
    [Console]::TreatControlCAsInput = $true;
    [Console]::CursorVisible = $false;
    Clear-Host;
    Start-Server;

    while ($true) {
        $dirty = $false;

        $line = $null;
        while ($script:Queue.TryDequeue([ref]$line)) { Add-LogLine $line; $dirty = $true };

        if (((Get-Date) - $lastProbe).TotalSeconds -ge 2) {
            $lastProbe = Get-Date;
            if ($script:Proc -and -not $script:Proc.HasExited) {
                $script:Healthy = Test-Health;
                Update-SlotsFromApi;
            } else {
                $script:Healthy = $false;
            }
            $script:Gpu = Get-Gpu;
            $dirty = $true;
        }

        while ([Console]::KeyAvailable) {
            $k = [Console]::ReadKey($true);
            $ctrlC = ($k.Key -eq 'C') -and (($k.Modifiers -band [ConsoleModifiers]::Control) -ne 0);
            if ($ctrlC -or $k.Key -eq 'Q') { return };
            switch ($k.Key) {
                'R' { Set-Flash "Restarting multimodal server..."; Stop-Server; Start-Server }
                'M' {
                    $script:ParallelSlots = if ($script:ParallelSlots -eq 1) { 2 } elseif ($script:ParallelSlots -eq 2) { 4 } else { 1 };
                    $mName = if ($script:ParallelSlots -eq 1) { "APEX-1 (100% Full Power)" }
                             elseif ($script:ParallelSlots -eq 2) { "DUO-2 Hybrid (2 Slots)" }
                             else { "SWARM-4 (4 Slots)" };
                    $perSlot = [int]($script:ContextSize / $script:ParallelSlots);
                    Set-Flash "Mode -> $mName ($perSlot ctx/slot). Restarting...";
                    Stop-Server; Start-Server;
                }
                'X' {
                    $script:ContextSize = switch ($script:ContextSize) {
                        8192  { 16384 }
                        16384 { 32768 }
                        32768 { 65536 }
                        default { 8192 }
                    };
                    Set-Flash "Context -> $($script:ContextSize) tokens. Restarting...";
                    Stop-Server; Start-Server;
                }
                'K' {
                    $script:KvCacheType = if ($script:KvCacheType -eq "q4_0") { "q8_0" } else { "q4_0" };
                    Set-Flash "KV Cache Quantization -> $($script:KvCacheType). Restarting...";
                    Stop-Server; Start-Server;
                }
                'N' {
                    $script:IsLocal = -not $script:IsLocal;
                    $modeName = if ($script:IsLocal) { "LocalOnly (127.0.0.1)" } else { "LAN Open (0.0.0.0)" };
                    Set-Flash "Network -> $modeName. Restarting...";
                    Stop-Server; Start-Server;
                }
                'O' { Start-Process "http://127.0.0.1:$Port"; Set-Flash "Opened web UI in browser" }
                'C' {
                    $clipUrl = if (-not $script:IsLocal -and $script:LanIp) { "http://$($script:LanIp):$Port/v1" } else { "http://127.0.0.1:$Port/v1" };
                    Set-Clipboard $clipUrl;
                    Set-Flash "Copied $clipUrl to clipboard";
                }
                'L' { $script:Filtered = -not $script:Filtered }
            }
            $dirty = $true;
        }

        $size = "$([Console]::WindowWidth)x$([Console]::WindowHeight)";
        if ($size -ne $lastSize) { Clear-Host; $lastSize = $size; $dirty = $true };

        if ($dirty -or ((Get-Date) - $lastRender).TotalMilliseconds -ge 1000) {
            Render;
            $lastRender = Get-Date;
        }
        Start-Sleep -Milliseconds 120;
    }
}
finally {
    Stop-Server;
    foreach ($id in 'aton.out', 'aton.err') { Unregister-Event -SourceIdentifier $id -ErrorAction SilentlyContinue };
    [Console]::TreatControlCAsInput = $oldCtrl;
    [Console]::OutputEncoding       = $oldEnc;
    [Console]::CursorVisible        = $true;
}
