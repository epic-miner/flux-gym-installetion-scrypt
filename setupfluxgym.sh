#!/bin/bash

# Set up error handling
set -e

# Update and install required packages
echo "Updating package list and installing python3.10-venv..."
sudo apt update
sudo apt install -y python3.10-venv

# Clone Fluxgym and kohya-ss/sd-scripts repositories
echo "Cloning Fluxgym and kohya-ss/sd-scripts..."
git clone https://github.com/cocktailpeanut/fluxgym
cd fluxgym
git clone -b sd3 https://github.com/kohya-ss/sd-scripts
# Set up virtual environment
python -m venv env
#. env/bin/activate
# Install dependencies for sd-scripts
echo "Installing sd-scripts dependencies..."
cd sd-scripts
pip install -r requirements.txt

# Install app dependencies
echo "Installing app dependencies..."
cd ..
pip install -r requirements.txt

# Install PyTorch Nightly
echo "Installing PyTorch Nightly..."
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121

# Create models directory
echo "Setting up model directories..."
mkdir -p models/clip models/vae models/unet

# Download model files
echo "Downloading models..."
wget -O models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true
wget -O models/clip/t5xxl_fp16.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true
wget -O models/vae/ae.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/ae.sft?download=true
wget -O models/unet/flux1-dev.sft https://huggingface.co/cocktailpeanut/xulf-dev/resolve/main/flux1-dev.sft?download=true

# Final message
echo "Setup complete. To start the app, run the following commands:"
echo "python app.py"
