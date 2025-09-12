#!/usr/bin/env python3

import os
import shutil
from pathlib import Path

# Source directory
source_dir = "/Users/melikeseyitoglu/Documents/Talha/DeepLearningModelVisualization/Assets/StreamingAssets/feature_maps_alexnet/+ship"

# Destination directory
dest_dir = "/Users/melikeseyitoglu/Desktop/Visualization of DeepLearning/Visualization of DeepLearning/Assets.xcassets/Alexnet/ship"

# Layer mapping: source_layer_number -> (destination_folder, count)
layer_mapping = {
    0: ("conv1", 64),    # First 64 files from layer 0 -> conv1
    2: ("maxp1", 64),    # 64 files from layer 2 -> maxp1  
    3: ("conv2", 192),   # 192 files from layer 3 -> conv2
    5: ("maxp2", 192),   # 192 files from layer 5 -> maxp2
    6: ("conv3", 384),   # 384 files from layer 6 -> conv3
    8: ("conv4", 256),   # 256 files from layer 8 -> conv4
    10: ("conv5", 256),  # 256 files from layer 10 -> conv5
    12: ("maxp3", 256)   # 256 files from layer 12 -> maxp3
}

def copy_layer_files(source_layer, dest_layer, count):
    """Copy PNG files for a specific layer"""
    print(f"Copying {count} files from layer {source_layer} to {dest_layer}...")
    
    # Get all PNG files for this source layer
    source_files = []
    for i in range(1, count + 1):
        source_file = f"{source_layer}_feature_map_{i}.png"
        source_path = Path(source_dir) / source_file
        if source_path.exists():
            source_files.append(source_path)
    
    print(f"Found {len(source_files)} files for layer {source_layer}")
    
    # Copy files to destination
    for i, source_path in enumerate(source_files):
        # Destination: ship_{layer}_{index}.png
        dest_filename = f"ship_{dest_layer}_{i}.png"
        dest_imageset_dir = Path(dest_dir) / dest_layer / f"ship_{dest_layer}_{i}.imageset"
        dest_path = dest_imageset_dir / dest_filename
        
        # Create destination directory if it doesn't exist
        dest_imageset_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy the file
        try:
            shutil.copy2(source_path, dest_path)
            print(f"  Copied: {source_path.name} -> {dest_path}")
        except Exception as e:
            print(f"  Error copying {source_path.name}: {e}")

def main():
    print("Starting to copy PNG files from source to ship asset structure...")
    print(f"Source: {source_dir}")
    print(f"Destination: {dest_dir}")
    print()
    
    # Check if source directory exists
    if not Path(source_dir).exists():
        print(f"Error: Source directory does not exist: {source_dir}")
        return
    
    # Check if destination directory exists
    if not Path(dest_dir).exists():
        print(f"Error: Destination directory does not exist: {dest_dir}")
        return
    
    total_copied = 0
    
    # Copy files for each layer
    for source_layer, (dest_layer, count) in layer_mapping.items():
        copy_layer_files(source_layer, dest_layer, count)
        total_copied += count
        print()
    
    print(f"Finished! Total files copied: {total_copied}")

if __name__ == "__main__":
    main()
