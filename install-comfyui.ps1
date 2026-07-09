<#
.SYNOPSIS
    Install and configure ComfyUI with FARGO branding
#>

param(
    [switch]$Force,
    [switch]$SkipModels
)

$ErrorActionPreference = "Stop"

$installDir = "$env:USERPROFILE\ComfyUI"
$modelsDir = "$installDir\models"
$customNodesDir = "$installDir\custom_nodes"
$backupDir = "$installDir.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║        ComfyUI Installation with FARGO Branding              ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

Write-Host "`nInstall directory: $installDir" -ForegroundColor Cyan

# Check if already installed
if (Test-Path $installDir) {
    if ($Force) {
        Write-Host "Backing up existing installation..." -ForegroundColor Yellow
        Copy-Item $installDir $backupDir -Recurse -Force
        Write-Host "  Backup saved to: $backupDir" -ForegroundColor Green
        Remove-Item $installDir -Recurse -Force
    } else {
        Write-Host "ComfyUI already installed at $installDir" -ForegroundColor Yellow
        Write-Host "Use -Force to reinstall" -ForegroundColor Yellow
        exit 0
    }
}

# Check prerequisites
Write-Host "`n=== Checking Prerequisites ===" -ForegroundColor Cyan

# Check Python
$pythonVersion = python --version 2>&1
Write-Host "  Python: $pythonVersion"

# Check Git
$gitVersion = git --version 2>&1
Write-Host "  Git: $gitVersion"

# Check CUDA (NVIDIA GPU)
$cudaVersion = nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>&1 | Select-Object -First 1
if ($cudaVersion) {
    Write-Host "  NVIDIA Driver: $cudaVersion" -ForegroundColor Green
} else {
    Write-Host "  NVIDIA Driver: NOT FOUND (CPU mode will be used)" -ForegroundColor Yellow
}

# Clone ComfyUI
Write-Host "`n=== Cloning ComfyUI ===" -ForegroundColor Cyan
git clone https://github.com/comfyanonymous/ComfyUI.git $installDir
Set-Location $installDir

# Install Python dependencies
Write-Host "`n=== Installing Python Dependencies ===" -ForegroundColor Cyan
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# Install additional dependencies for FARGO
Write-Host "`n=== Installing FARGO Dependencies ===" -ForegroundColor Cyan
$fargoDeps = @(
    "torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121",
    "transformers",
    "accelerate",
    "safetensors",
    "pillow",
    "numpy",
    "opencv-python",
    "scikit-image",
    "einops",
    "omegaconf"
)

foreach ($dep in $fargoDeps) {
    Write-Host "  Installing: $dep" -ForegroundColor Gray
    python -m pip install $dep
}

# Create directory structure
Write-Host "`n=== Creating Directory Structure ===" -ForegroundColor Cyan
$dirs = @(
    "models\checkpoints",
    "models\loras",
    "models\embeddings",
    "models\vae",
    "models\controlnet",
    "models\upscale_models",
    "models\clip",
    "outputs",
    "input",
    "temp"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Path "$installDir\$dir" -Force | Out-Null
    Write-Host "  [OK] $dir" -ForegroundColor Green
}

# Install custom nodes
Write-Host "`n=== Installing Custom Nodes ===" -ForegroundColor Cyan
$customNodes = @(
    "https://github.com/ltdrdata/ComfyUI-Manager.git",
    "https://github.com/comfyanonymous/ComfyUI_custom_nodes.git"
)

foreach ($node in $customNodes) {
    $nodeName = Split-Path $node -LeafBase
    $nodePath = "$customNodesDir\$nodeName"
    
    if (-not (Test-Path $nodePath)) {
        Write-Host "  Installing: $nodeName" -ForegroundColor Gray
        git clone $node $nodePath
        Write-Host "  [OK] $nodeName" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] $nodeName (already exists)" -ForegroundColor Yellow
    }
}

# Create FARGO branding config
Write-Host "`n=== Applying FARGO Branding ===" -ForegroundColor Cyan
$fargoConfig = @"
# FARGO Branding Configuration
[fargo]
name = "FARGO"
version = "1.0.0"
description = "ZQM-Computing AI Image Generation Suite"
author = "ZQM-Computing"
url = "https://github.com/ZQM-Computing/comfy-custom"

[ui]
theme = "dark"
primary_color = "#00ff88"  # ZQM green
logo = "fargo-logo.png"
show_watermark = true
watermark_text = "FARGO by ZQM-Computing"

[defaults]
model = "sd_xl_base_1.0.safetensors"
vae = "sdxl_vae.safetensors"
clip = "clip_l.safetensors"
steps = 30
cfg_scale = 7.0
width = 1024
height = 1024
batch_size = 1

[paths]
models = "models/checkpoints"
loras = "models/loras"
embeddings = "models/embeddings"
output = "outputs"
input = "input"
"@

Set-Content -Path "$installDir\fargo-config.ini" -Value $fargoConfig -Force
Write-Host "  [OK] fargo-config.ini" -ForegroundColor Green

# Create desktop shortcut
Write-Host "`n=== Creating Desktop Shortcut ===" -ForegroundColor Cyan
$shortcutPath = "$env:USERPROFILE\Desktop\FARGO ComfyUI.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "python"
$shortcut.Arguments = "$installDir\main.py"
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = "$installDir\fargo-icon.ico"
$shortcut.Save()
Write-Host "  [OK] Desktop shortcut created" -ForegroundColor Green

# Create startup script
Write-Host "`n=== Creating Startup Script ===" -ForegroundColor Cyan
$startScript = @"
@echo off
cd /d "$installDir"
echo Starting FARGO ComfyUI...
python main.py --auto-launch
pause
"@

Set-Content -Path "$installDir\start-fargo.bat" -Value $startScript -Force
Write-Host "  [OK] start-fargo.bat" -ForegroundColor Green

# Download default models (optional)
if (-not $SkipModels) {
    Write-Host "`n=== Downloading Default Models ===" -ForegroundColor Cyan
    Write-Host "  NOTE: Model download requires ~7GB of disk space" -ForegroundColor Yellow
    $response = Read-Host "  Download SDXL base model? (y/N)"
    
    if ($response -eq "y" -or $response -eq "Y") {
        $modelUrl = "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors"
        $modelPath = "$modelsDir\checkpoints\sd_xl_base_1.0.safetensors"
        
        Write-Host "  Downloading SDXL base model (this may take a while)..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $modelUrl -OutFile $modelPath
        Write-Host "  [OK] SDXL base model downloaded" -ForegroundColor Green
    }
}

# Verify installation
Write-Host "`n=== Installation Summary ===" -ForegroundColor Cyan
$installedFiles = Get-ChildItem $installDir -File | Measure-Object | Select-Object -ExpandProperty Count
$installedDirs = Get-ChildItem $installDir -Directory | Measure-Object | Select-Object -ExpandProperty Count
Write-Host "  Files installed: $installedFiles"
Write-Host "  Directories created: $installedDirs"

# Check critical files
Write-Host "`n=== Validation ===" -ForegroundColor Cyan
$criticalFiles = @("main.py", "requirements.txt", "fargo-config.ini")
foreach ($file in $criticalFiles) {
    $path = Join-Path $installDir $file
    if (Test-Path $path) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $file MISSING" -ForegroundColor Red
    }
}

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║  Installation Complete                                        ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review config at: $installDir\fargo-config.ini"
Write-Host "  2. Download models to: $modelsDir\checkpoints"
Write-Host "  3. Start ComfyUI: $installDir\start-fargo.bat"
Write-Host "  4. Open browser to: http://localhost:8188"
Write-Host "`nFor more info, see: https://github.com/comfyanonymous/ComfyUI"