# PowerShell helper to publish Akhet-Ra1 to Hugging Face
param(
    [string]$Token = "",
    [switch]$OnlyDocs,
    [switch]$OnlyModel
)

$ErrorActionPreference = "Stop"

Write-Host "=== Akhet-Ra1 Hugging Face Publisher ===" -ForegroundColor Cyan

# Check if huggingface_hub is installed
try {
    python -c "import huggingface_hub" 2>$null
} catch {
    Write-Host "Installing huggingface_hub..." -ForegroundColor Yellow
    pip install -U "huggingface_hub[hf_transfer]"
}

$scriptPath = Join-Path $PSScriptRoot "upload_to_hf.py"

$cmdArgs = @()
if ($Token) {
    $cmdArgs += "--token"
    $cmdArgs += "$Token"
}
if ($OnlyDocs) {
    $cmdArgs += "--only-docs"
}
if ($OnlyModel) {
    $cmdArgs += "--only-model"
}

if (Get-Command py -ErrorAction SilentlyContinue) {
    py -3.14 "$scriptPath" @cmdArgs
} else {
    python "$scriptPath" @cmdArgs
}

