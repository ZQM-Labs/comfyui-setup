<#
.SYNOPSIS
    Download essential models for FARGO ComfyUI
#>

$modelsDir = "$env:USERPROFILE\ComfyUI\models"

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║        FARGO Model Downloader                                 ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

# SDXL Base Model
$sdxlUrl = "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
$sdxlPath = "$modelsDir\checkpoints\sd_xl_base_1.0.safetensors"

if (-not (Test-Path $sdxlPath)) {
    Write-Host "`nDownloading SDXL Base Model (~7GB)..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path "$modelsDir\checkpoints" -Force | Out-Null
    Invoke-WebRequest -Uri $sdxlUrl -OutFile $sdxlPath
    Write-Host "  [OK] SDXL Base Model downloaded" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] SDXL Base Model already exists" -ForegroundColor Yellow
}

# SDXL VAE
$vaeUrl = "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sdxl_vae.safetensors"
$vaePath = "$modelsDir\vae\sdxl_vae.safetensors"

if (-not (Test-Path $vaePath)) {
    Write-Host "`nDownloading SDXL VAE..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path "$modelsDir\vae" -Force | Out-Null
    Invoke-WebRequest -Uri $vaeUrl -OutFile $vaePath
    Write-Host "  [OK] SDXL VAE downloaded" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] SDXL VAE already exists" -ForegroundColor Yellow
}

# SDXL Refiner
$refinerUrl = "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors"
$refinerPath = "$modelsDir\checkpoints\sd_xl_refiner_1.0.safetensors"

if (-not (Test-Path $refinerPath)) {
    Write-Host "`nDownloading SDXL Refiner (~7GB)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $refinerUrl -OutFile $refinerPath
    Write-Host "  [OK] SDXL Refiner downloaded" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] SDXL Refiner already exists" -ForegroundColor Yellow
}

# CLIP Models
$clipLUrl = "https://huggingface.co/comfyanonymous/openclip-prior-v0/resolve/main/vit-l-14/openclip_pytorch_model.safetensors"
$clipLPath = "$modelsDir\clip\clip_l.safetensors"

if (-not (Test-Path $clipLPath)) {
    Write-Host "`nDownloading CLIP L..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path "$modelsDir\clip" -Force | Out-Null
    Invoke-WebRequest -Uri $clipLUrl -OutFile $clipLPath
    Write-Host "  [OK] CLIP L downloaded" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] CLIP L already exists" -ForegroundColor Yellow
}

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║  Model Download Complete                                       ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

Write-Host "Models installed to: $modelsDir" -ForegroundColor Green
Write-Host "Restart ComfyUI to load new models" -ForegroundColor Yellow