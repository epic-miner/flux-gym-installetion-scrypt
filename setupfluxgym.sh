#!/bin/bash

# Set up error handling
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install python3.10-venv if not already installed
if ! dpkg -s python3.10-venv >/dev/null 2>&1; then
    echo "Installing python3.10-venv..."
    sudo apt update
    sudo apt install -y python3.10-venv
else
    echo "python3.10-venv is already installed, skipping..."
fi

# Clone Fluxgym if it doesn't exist
if [ ! -d "fluxgym" ]; then
    echo "Cloning Fluxgym..."
    git clone https://github.com/cocktailpeanut/fluxgym
else
    echo "Fluxgym directory already exists, skipping clone..."
fi
cd fluxgym

# Clone kohya-ss/sd-scripts if it doesn't exist
if [ ! -d "sd-scripts" ]; then
    echo "Cloning sd-scripts..."
    git clone -b sd3 https://github.com/kohya-ss/sd-scripts
else
    echo "sd-scripts directory already exists, skipping clone..."
fi

# Set up virtual environment if it doesn't exist
if [ ! -d "env" ]; then
    echo "Setting up virtual environment..."
    python3 -m venv env
else
    echo "Virtual environment already exists, skipping setup..."
fi
source env/bin/activate

# Install dependencies for sd-scripts
cd sd-scripts
if [ -f "requirements.txt" ]; then
    echo "Installing sd-scripts dependencies..."
    pip install -r requirements.txt
else
    echo "requirements.txt not found in sd-scripts, skipping dependency installation..."
fi

# Install app dependencies
cd ..
if [ -f "requirements.txt" ]; then
    echo "Installing app dependencies..."
    pip install -r requirements.txt
else
    echo "requirements.txt not found in fluxgym, skipping dependency installation..."
fi

# Install PyTorch Nightly if not installed
if ! pip show torch | grep -q "nightly"; then
    echo "Installing PyTorch Nightly..."
    pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121
else
    echo "PyTorch Nightly already installed, skipping..."
fi

# Create model directories if they don't exist
echo "Setting up model directories..."
mkdir -p models/clip models/vae models/unet

# Download models if not already present
if [ ! -f "models/clip/clip_l.safetensors" ]; then
    echo "Downloading clip_l.safetensors..."
    wget -O models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true
else
    echo "clip_l.safetensors already exists, skipping download..."
fi

if [ ! -f "models/clip/t5xxl_fp16.safetensors" ]; then
    echo "Downloading t5xxl_fp16.safetensors..."
    wget -O models/clip/t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true
else
    echo "t5xxl_fp16.safetensors already exists, skipping download..."
fi

if [ ! -f "models/vae/ae.sft" ]; then
    echo "Downloading ae.sft..."
    wget -O models/vae/ae.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/ae.sft?download=true
else
    echo "ae.sft already exists, skipping download..."
fi

if [ ! -f "models/unet/flux1-dev.sft" ]; then
    echo "Downloading flux1-dev.sft..."
    wget -O models/unet/flux1-dev.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/flux1-dev.sft?download=true
else
    echo "flux1-dev.sft already exists, skipping download..."
fi

# Final message
echo "Setup complete. To start the app, run the following commands:"
echo "source env/bin/activate"
echo "python app.py"
