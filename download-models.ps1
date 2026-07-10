<#
.SYNOPSIS
    Download essential models for FARGO ComfyUI
#>

$modelsDir = "$env:USERPROFILE\ComfyUI\models"

function Download-Model {
    param(
        [string[]]$Urls,
        [string]$OutputPath,
        [string]$Description,
        [long]$ExpectedSize = 0,
        [int]$MaxRetries = 3
    )
    
    $directory = Split-Path $OutputPath -Parent
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
    
    if (Test-Path $OutputPath) {
        $fileSize = (Get-Item $OutputPath).Length
        if ($ExpectedSize -gt 0 -and $fileSize -lt $ExpectedSize * 0.9) {
            Write-Host "  [RE-DOWNLOAD] $Description (incomplete: $($fileSize/1GB.ToString('0.00'))GB, expected: $($ExpectedSize/1GB.ToString('0.00'))GB)" -ForegroundColor Yellow
            Remove-Item $OutputPath -Force
        } else {
            Write-Host "  [SKIP] $Description already exists" -ForegroundColor Yellow
            return $true
        }
    }
    
    Write-Host "`nDownloading $Description..." -ForegroundColor Cyan
    
    foreach ($url in $Urls) {
        for ($i = 1; $i -le $MaxRetries; $i++) {
            Write-Host "  Attempt $i/$MaxRetries from: $url" -ForegroundColor Gray
            try {
                $webClient = New-Object System.Net.WebClient
                $webClient.Timeout = 300000  # 5 minutes timeout
                $webClient.DownloadFile($url, $OutputPath)
                $webClient.Dispose()
                
                if (Test-Path $OutputPath) {
                    $fileSize = (Get-Item $OutputPath).Length
                    if ($ExpectedSize -eq 0 -or $fileSize -ge $ExpectedSize * 0.9) {
                        Write-Host "  [OK] $Description downloaded ($($fileSize/1MB.ToString('0'))MB)" -ForegroundColor Green
                        return $true
                    }
                }
            } catch {
                Write-Host "  [WARN] Attempt $i failed: $($_.Exception.Message)" -ForegroundColor Yellow
                if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
            }
        }
    }
    
    Write-Host "  [ERROR] Failed to download $Description after $MaxRetries attempts" -ForegroundColor Red
    return $false
}

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║        FARGO Model Downloader                                 ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

# SDXL Base Model (~7GB)
$sdxlUrls = @(
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
)
$sdxlPath = "$modelsDir\checkpoints\sd_xl_base_1.0.safetensors"
Download-Model -Urls $sdxlUrls -OutputPath $sdxlPath -Description "SDXL Base Model" -ExpectedSize 7GB

# SDXL VAE (~334MB)
$vaeUrls = @(
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sdxl_vae.safetensors"
)
$vaePath = "$modelsDir\vae\sdxl_vae.safetensors"
Download-Model -Urls $vaeUrls -OutputPath $vaePath -Description "SDXL VAE" -ExpectedSize 334MB

# SDXL Refiner (~7GB)
$refinerUrls = @(
    "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors"
)
$refinerPath = "$modelsDir\checkpoints\sd_xl_refiner_1.0.safetensors"
Download-Model -Urls $refinerUrls -OutputPath $refinerPath -Description "SDXL Refiner" -ExpectedSize 7GB

# CLIP L (~2.5GB) - using alternative sources
$clipLUrls = @(
    "https://huggingface.co/comfyanonymous/openclip-prior-v0/resolve/main/vit-l-14/openclip_pytorch_model.safetensors",
    "https://civitai.com/api/download/models/152170"
)
$clipLPath = "$modelsDir\clip\clip_l.safetensors"
Download-Model -Urls $clipLUrls -OutputPath $clipLPath -Description "CLIP L" -ExpectedSize 2.5GB

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║  Model Download Complete                                       ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

Write-Host "Models installed to: $modelsDir" -ForegroundColor Green
Write-Host "Restart ComfyUI to load new models" -ForegroundColor Yellow