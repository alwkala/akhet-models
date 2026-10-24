$env:PATH = "A:\llama-cpp;" + $env:PATH
$modelPath = "A:\.lmstudio\Akhet\Ra-1\Ra-1-4B-Q4_K_M.gguf"
$systemPromptPath = "A:\.lmstudio\Akhet\Ra-1\system_prompt.txt"
$gpuLayers = 99          # 100% GPU offload (fits completely in 6GB VRAM)
$contextSize = 32768     # 32K context for deep reasoning and creative chains
$threads = 8

Write-Host "Starting Akhet-Ra 1 with CUDA GPU acceleration (32K Context)..." -ForegroundColor Green
Write-Host "Model: $modelPath" -ForegroundColor Cyan
Write-Host "System Prompt: $systemPromptPath" -ForegroundColor Yellow

llama-server.exe `
  -m $modelPath `
  --alias Akhet-Ra-1 `
  -ngl $gpuLayers `
  -c $contextSize `
  -t $threads `
  --jinja `
  --flash-attn on `
  -ctk q4_0 `
  -ctv q4_0 `
  --batch-size 1024 `
  --ubatch-size 512 `
  --parallel 1 `
  --host 0.0.0.0 `
  --port 8080
