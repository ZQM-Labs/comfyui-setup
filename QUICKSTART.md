# FARGO ComfyUI Quick Start Guide

## What is FARGO?

FARGO (F**AI**l **R**esilient **G**eneration **O**rchestration) is ZQM-Computing's branded ComfyUI installation for AI image generation.

## Quick Start

### 1. Start ComfyUI
```powershell
# Option A: Desktop shortcut
# Double-click "FARGO ComfyUI" on desktop

# Option B: Command line
cd C:\Users\zqmco\ComfyUI
python main.py

# Option C: Batch file
C:\Users\zqmco\ComfyUI\start-fargo.bat
```

### 2. Open Web Interface
Navigate to: **http://localhost:8188**

### 3. Download Models
Place model files in:
- `C:\Users\zqmco\ComfyUI\models\checkpoints\` - Main models (SDXL, SD 1.5)
- `C:\Users\zqmco\ComfyUI\models\loras\` - LoRA adapters
- `C:\Users\zqmco\ComfyUI\models\vae\` - VAE models
- `C:\Users\zqmco\ComfyUI\models\controlnet\` - ControlNet models

## Basic Workflow

### Text-to-Image
1. Click "Load Default" to load empty workflow
2. Add nodes: Right-click → "Add Node"
3. Add "Load Checkpoint" → Select your model
4. Add "CLIP Text Encode" → Enter your prompt
5. Add "KSampler" → Set steps (20-30), CFG (7-8)
6. Add "Save Image" → Set output path
7. Click "Queue Prompt" to generate

### Image-to-Image
1. Add "Load Image" node
2. Add "Load Checkpoint" node
3. Add "CLIP Text Encode" for prompt
4. Add "KSampler" with denoising (0.3-0.7)
5. Add "Save Image" node

## FARGO Configuration

Edit `C:\Users\zqmco\ComfyUI\fargo-config.ini`:
```ini
[fargo]
name = "FARGO"
version = "1.0.0"

[ui]
theme = "dark"
primary_color = "#00ff88"  # ZQM green

[defaults]
model = "sd_xl_base_1.0.safetensors"
steps = 30
cfg_scale = 7.0
width = 1024
height = 1024
```

## ZQM Integration Ideas

### Security Research Visualization
- Generate diagrams of attack vectors
- Create visual reports of findings
- Create custom infosec-themed models

### Workflow Automation
- Create batch processing scripts
- Integrate with Hermes agent skills
- Auto-generate report images

## Useful Links

- [ComfyUI Documentation](https://docs.comfy.org)
- [Model Database](https://civitai.com)
- [ZQM-Computing comfy-custom](https://github.com/ZQM-Computing/comfy-custom)

## Troubleshooting

### GPU Not Detected
- Ensure NVIDIA drivers are installed
- Check CUDA version compatibility
- Run: `nvidia-smi` in terminal

### Out of Memory
- Reduce image resolution (512x512)
- Use `--lowvram` flag: `python main.py --lowvram`
- Enable model CPU offloading

### Models Not Loading
- Check file extension (.safetensors, .ckpt)
- Verify model path in config
- Restart ComfyUI after adding models