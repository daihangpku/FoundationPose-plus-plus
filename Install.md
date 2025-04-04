# Installation

## Build FoundationPose
```bash
# Enter the container, git clone this repo:
git clone https://github.com/teal024/FoundationPose-plus-plus

# Export project root as the dir of the repo
export PROJECT_ROOT=~/foundationpose/FoundationPose-plus-plus

# Download FoundationPose weights to $PROJECT_ROOT/FoundationPose/weights
from Google Drive: https://drive.google.com/drive/folders/1DFezOAD0oD1BblsXVxqDsl8fj0qzB82i

# Start building process
cd $PROJECT_ROOT/FoundationPose
```

## Setting the environment for foundation pose
```bash
# create conda environment
conda create -n foundationpose python=3.9

# activate conda environment
conda activate foundationpose

# Install Eigen3 3.4.0 under conda environment
conda install conda-forge::eigen=3.4.0
export CMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH:/eigen/path/under/conda"

# install dependencies
python -m pip install -r requirements.txt

# Install NVDiffRast
python -m pip install --quiet --no-cache-dir git+https://github.com/NVlabs/nvdiffrast.git

# Kaolin (Optional, needed if running model-free setup)
python -m pip install --quiet --no-cache-dir kaolin==0.15.0 -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.0.0_cu118.html

# PyTorch3D
python -m pip install --quiet --no-index --no-cache-dir pytorch3d -f https://dl.fbaipublicfiles.com/pytorch3d/packaging/wheels/py39_cu118_pyt200/download.html

# Build extensions
CMAKE_PREFIX_PATH=$CONDA_PREFIX/lib/python3.9/site-packages/pybind11/share/cmake/pybind11 bash build_all_conda.sh
```







## Utilities

```bash
# For Cutie
cd $PROJECT_ROOT/Cutie
pip install -e .
python cutie/utils/download_models.py

```
