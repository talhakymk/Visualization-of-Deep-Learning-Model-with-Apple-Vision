//
//  LenetCubes.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 28.08.2025.
//

import Foundation
import RealityKit
import UIKit

func makeLenetCubesAnchor(labels: [String] = ["CONVOLUTION 1\n(27x27x6)", "MAXPOOLING 1\n13x13x6", "CONVOLUTION 2\n9x9x16", "MAXPOOLING 2\n4x4x16"]) -> Entity {
    let anchor = Entity()
    anchor.name = "LenetCubesAnchor"
    
    let cubeSize: Float = 0.2
    let cubeSpacing: Float = 0.8
    let startX: Float = -((cubeSpacing * 3) / 2.0)
    
    for i in 0..<4 {
        // Her küp için farklı mavi-mor tonları
        let cubeColors: [UIColor] = [
            UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),   // Açık mavi
            UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0),   // Koyu mavi
            UIColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0),   // Mor-mavi
            UIColor(red: 0.8, green: 0.2, blue: 0.8, alpha: 1.0)    // Mor
        ]
        
        // mesh ve metalik material
        let mesh = MeshResource.generateBox(size: cubeSize)
        var material = SimpleMaterial()
        material.color = .init(tint: cubeColors[i], texture: nil)
        material.metallic = .float(0.8)        // Metalik parlaklık
        material.roughness = .float(0.2)       // Düşük pürüz
        
        let cube = ModelEntity(mesh: mesh, materials: [material])
        cube.name = "LenetCube_\(i)"
        
        // Tıklanabilirlik
        cube.components.set(CollisionComponent(shapes: [.generateBox(size: [cubeSize, cubeSize, cubeSize])]))
        cube.components.set(InputTargetComponent())
        cube.components.set(HoverEffectComponent())
        
        // Küpleri konumlandırırken yatayk konumlandıralım
        let x = startX + Float(i) * cubeSpacing
        cube.position = SIMD3<Float>(x, 0, 0)
        
        let labelText = labels[i]
        let textMesh = MeshResource.generateText(
            labelText,
            extrusionDepth: 0.001,
            font: UIFont.systemFont(ofSize: 0.04, weight: .semibold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        // metin materyali
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.name = "LenetCubeLabel_\(i)"
            
        let yBelow = -(cubeSize / 2.0) - 0.06 - 0.2
        textEntity.position = SIMD3<Float>(x - 0.16, yBelow, 0)
        anchor.addChild(textEntity)

        anchor.addChild(cube)
    }
    
    return anchor
}

