//
//  AlexNetNeuralNetwork.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 03.09.2025.
//

import Foundation
import RealityKit
import UIKit

// AlexNet Neural Network Model
func makeAlexNetNeuralNetworkAnchor() -> Entity {
    let anchor = Entity()
    anchor.name = "AlexNetNeuralNetworkAnchor"
    
    let sphereRadius: Float = 0.05
    let layerSpacing: Float = 0.6
    
    // Her layer için farklı renkler
    let layerColors: [UIColor] = [
        UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0),   // Açık mavi
        UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0),   // Orta mavi
        UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0),   // Koyu mavi
        UIColor(red: 0.0, green: 0.2, blue: 0.7, alpha: 1.0)    // En koyu mavi
    ]
    
    // Y pozisyonları
    let neuronYPositions: [Float] = [
        0.7,
        0.4,
        0.1,
        -0.7
    ]
    
    // 4 layer her layerda 4 nöron
    for layerIndex in 0..<4 {
        for neuronIndex in 0..<4 {
            // Sphere mesh ve material
            let mesh = MeshResource.generateSphere(radius: sphereRadius)
            var material = SimpleMaterial()
            material.color = .init(tint: layerColors[layerIndex], texture: nil)
            material.metallic = .float(0.6)
            material.roughness = .float(0.3)
            
            let sphere = ModelEntity(mesh: mesh, materials: [material])
            sphere.name = "AlexNetNeuron_L\(layerIndex)_N\(neuronIndex)"
            
            // Pozisyon hesaplama
            let x = Float(layerIndex) * layerSpacing  // Layer pozisyonu
            let y = neuronYPositions[neuronIndex]     // Manuel Y pozisyonu
            let z: Float = 0  // Z sabit
            
            sphere.position = SIMD3<Float>(x, y, z)
            
            // Tıklanabilirlik
            sphere.components.set(CollisionComponent(shapes: [.generateSphere(radius: sphereRadius)]))
            sphere.components.set(InputTargetComponent())
            sphere.components.set(HoverEffectComponent())
            
            anchor.addChild(sphere)
        }
    }
    
    return anchor
}

// AlexNet Neural Network bağlantı çizgilerini oluşturan fonksiyon
func makeAlexNetConnectionLines() -> Entity {
    let anchor = Entity()
    anchor.name = "AlexNetConnectionLinesAnchor"
    
    let layerSpacing: Float = 0.6
    let neuronYPositions: [Float] = [0.7, 0.4, 0.1, -0.7]
    
    let lineThickness: Float = 0.003 // İnce çizgi
    
    // İnce beyaz çizgi materyali
    var lineMaterial = SimpleMaterial()
    lineMaterial.color = .init(tint: UIColor.white, texture: nil)
    lineMaterial.metallic = .float(0.0)
    lineMaterial.roughness = .float(0.1)
    
    // 3 layer arası bağlantı - SADECE KOMŞU LAYERLAR
    for sourceLayer in 0..<3 {
        let targetLayer = sourceLayer + 1
        
        print("🔗 Creating connections from layer \(sourceLayer) to layer \(targetLayer)")
        
        // Source layerdaki her nöron
        for sourceNeuron in 0..<4 {
            // Target layerdaki her nöron
            for targetNeuron in 0..<4 {
                
                let startPos = SIMD3<Float>(
                    Float(sourceLayer) * layerSpacing,
                    neuronYPositions[sourceNeuron],
                    0
                )
                let endPos = SIMD3<Float>(
                    Float(targetLayer) * layerSpacing,
                    neuronYPositions[targetNeuron],
                    0
                )
                
                print("🔗   Connection: L\(sourceLayer)N\(sourceNeuron) (\(startPos)) → L\(targetLayer)N\(targetNeuron) (\(endPos))")
                
                // Çizgi oluşturma
                let connectionLine = createConnectionLine(
                    from: startPos,
                    to: endPos,
                    thickness: lineThickness,
                    material: lineMaterial
                )
                
                connectionLine.name = "AlexNetConnection_L\(sourceLayer)N\(sourceNeuron)_to_L\(targetLayer)N\(targetNeuron)"
                anchor.addChild(connectionLine)
            }
        }
    }
    
    return anchor
}

// İki nokta arasında çizgi oluşturan helper fonksiyon
private func createConnectionLine(from startPos: SIMD3<Float>, to endPos: SIMD3<Float>, thickness: Float, material: SimpleMaterial) -> ModelEntity {
    
    // İki nokta arasındaki mesafe ve yön
    let direction = endPos - startPos
    let distance = length(direction)
    let normalizedDirection = normalize(direction)
    
    // Cylinder mesh oluştur 
    let mesh = MeshResource.generateCylinder(height: distance, radius: thickness)
    let line = ModelEntity(mesh: mesh, materials: [material])
    
    // Çizgiyi iki nokta arasında konumlandır ve döndür
    let midPoint = (startPos + endPos) / 2
    line.position = midPoint
    
    // Çizgiyi doğru yöne döndür
    let defaultDirection = SIMD3<Float>(0, 1, 0) // Cylinder'ın varsayılan yönü
    let rotationAxis = cross(defaultDirection, normalizedDirection)
    let rotationAngle = acos(dot(defaultDirection, normalizedDirection))
    
    if length(rotationAxis) > 0.001 {
        let normalizedRotationAxis = normalize(rotationAxis)
        line.orientation = simd_quatf(angle: rotationAngle, axis: normalizedRotationAxis)
    }
    
    return line
}

// AlexNet Neural Network layer labellarını oluşturan fonksiyon
func makeAlexNetLayerLabels() -> Entity {
    let anchor = Entity()
    anchor.name = "AlexNetLayerLabelsAnchor"
    
    let layerSpacing: Float = 0.6    // Layerlar arası mesafe 
    let labelYPosition: Float = -1.0  // Labelları en alt nöronun altında
    
    // Layer sayıları
    let layerCounts = ["1000", "4096", "4096", "9216"]
    
    // 4 layer için labellar
    for layerIndex in 0..<4 {
        // Label text mesh
        let labelText = layerCounts[layerIndex]
        let textMesh = MeshResource.generateText(
            labelText,
            extrusionDepth: 0.001,
            font: UIFont.systemFont(ofSize: 0.06, weight: .bold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        // Metin materyali
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.name = "AlexNetLayerLabel_\(layerIndex)"
        
        // Label pozisyonu - layerın tam altında
        let x = Float(layerIndex) * layerSpacing
        textEntity.position = SIMD3<Float>(x + 0.08, labelYPosition, 0)  // -0.08 offset text merkezlemek için
        
        // Labelları kullanıcıya dönecek şekilde 180 döndür
        textEntity.transform.rotation = simd_quatf(angle: Float.pi, axis: SIMD3<Float>(0, 1, 0))
        
        anchor.addChild(textEntity)
    }
    
    return anchor
}
