#!/usr/bin/env python3

import os
import json

# Base path for Alexnet
alexnet_path = "/Users/melikeseyitoglu/Desktop/Visualization of DeepLearning/Visualization of DeepLearning/Assets.xcassets/Alexnet"

# Animal/input types
animals = ["ship"]  # ship klasörünü oluşturacağız

# Layer configurations: (layer_name, count)
layers = [
    ("conv1", 64),
    ("maxp1", 64),
    ("conv2", 192), 
    ("maxp2", 192),
    ("conv3", 384),
    ("conv4", 256),
    ("conv5", 256), 
    ("maxp3", 256)
]

# Contents.json template for folders
folder_contents = {
    "info": {
        "author": "xcode",
        "version": 1
    }
}

# Contents.json template for imagesets
imageset_contents_template = {
    "images": [
        {
            "filename": "",  # Will be filled
            "idiom": "universal"
        }
    ],
    "info": {
        "author": "xcode", 
        "version": 1
    }
}

for animal in animals:
    animal_path = os.path.join(alexnet_path, animal)
    
    # Create animal folder
    os.makedirs(animal_path, exist_ok=True)
    
    # Create Contents.json for animal folder
    animal_contents_path = os.path.join(animal_path, "Contents.json")
    with open(animal_contents_path, 'w') as f:
        json.dump(folder_contents, f, indent=2)
    
    print(f"✅ Created {animal} folder")
    
    for layer_name, count in layers:
        layer_path = os.path.join(animal_path, layer_name)
        
        # Create layer folder
        os.makedirs(layer_path, exist_ok=True)
        
        # Create Contents.json for layer
        layer_contents_path = os.path.join(layer_path, "Contents.json")
        with open(layer_contents_path, 'w') as f:
            json.dump(folder_contents, f, indent=2)
        
        print(f"  ✅ Created {animal}/{layer_name} folder")
        
        # Create imagesets
        for i in range(count):
            imageset_name = f"{animal}_{layer_name}_{i}.imageset"
            imageset_path = os.path.join(layer_path, imageset_name)
            
            # Create imageset directory
            os.makedirs(imageset_path, exist_ok=True)
            
            # Create Contents.json for imageset
            imageset_contents = imageset_contents_template.copy()
            imageset_contents["images"][0]["filename"] = f"{animal}_{layer_name}_{i}.png"
            
            contents_path = os.path.join(imageset_path, "Contents.json")
            with open(contents_path, 'w') as f:
                json.dump(imageset_contents, f, indent=2)
        
        print(f"     ✅ Created {count} imagesets for {animal}/{layer_name}")

print(f"\n🎉 All {animal} folders and imagesets created successfully!")
print("📁 Structure:")
for animal in animals:
    print(f"  {animal}/")
    for layer_name, count in layers:
        print(f"    {layer_name}: {count} imagesets")
