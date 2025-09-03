//
//  AlexNetNeuralNetwork.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 03.09.2025.
//

import Foundation
import RealityKit
import UIKit

// AlexNet Neural Network Model (4 layer with 4 spheres each)
func makeAlexNetNeuralNetworkAnchor() -> Entity {
    let anchor = Entity()
    anchor.name = "AlexNetNeuralNetworkAnchor"
    
    let sphereRadius: Float = 0.05
    let layerSpacing: Float = 0.6    // Layer'lar arası mesafe
    
    // Her layer için farklı renkler (mavi tonları)
    let layerColors: [UIColor] = [
        UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0),   // Açık mavi
        UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0),   // Orta mavi
        UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0),   // Koyu mavi
        UIColor(red: 0.0, green: 0.2, blue: 0.7, alpha: 1.0)    // En koyu mavi
    ]
    
    // Manuel Y pozisyonları: 1-2 kısa, 2-3 kısa, 3-4 uzun
    let neuronYPositions: [Float] = [
        0.7,        // 1. nöron (en üst)
        0.4,        // 2. nöron (1'den kısa mesafe)
        0.1,       // 3. nöron (2'den kısa mesafe)
        -0.7        // 4. nöron (3'ten uzun mesafe)
    ]
    
    // 4 layer, her layer'da 4 nöron
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
    
    let layerSpacing: Float = 0.6    // Layer'lar arası mesafe (neuron anchor ile aynı)
    let neuronYPositions: [Float] = [0.7, 0.4, 0.1, -0.7]  // Nöron Y pozisyonları (neuron anchor ile aynı)
    
    let lineThickness: Float = 0.005  // Çizgi kalınlığı
    
    // Çizgi materyali
    var lineMaterial = SimpleMaterial()
    lineMaterial.color = .init(tint: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6), texture: nil)
    lineMaterial.metallic = .float(0.3)
    lineMaterial.roughness = .float(0.7)
    
    // 3 layer arası bağlantı (Layer 0→1, 1→2, 2→3)
    for sourceLayer in 0..<3 {
        let targetLayer = sourceLayer + 1
        
        // Source layer'daki her nöron
        for sourceNeuron in 0..<4 {
            // Target layer'daki her nöron
            for targetNeuron in 0..<4 {
                
                // Başlangıç ve bitiş pozisyonları
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
                
                // Çizgi oluştur
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
    
    // Çizgi için box mesh oluştur (uzunluk = distance, genişlik/yükseklik = thickness)
    let mesh = MeshResource.generateBox(size: SIMD3<Float>(distance, thickness, thickness))
    let line = ModelEntity(mesh: mesh, materials: [material])
    
    // Çizgiyi iki nokta arasına yerleştir
    let midPoint = (startPos + endPos) / 2
    line.position = midPoint
    
    // Çizgiyi doğru yöne döndür
    if distance > 0 {
        // X-ekseni ile direction arasındaki açıyı hesapla
        let xAxis = SIMD3<Float>(1, 0, 0)
        let rotationAxis = cross(xAxis, normalizedDirection)
        let rotationAngle = acos(dot(xAxis, normalizedDirection))
        
        if length(rotationAxis) > 0.001 {
            let normalizedRotationAxis = normalize(rotationAxis)
            line.transform.rotation = simd_quatf(angle: rotationAngle, axis: normalizedRotationAxis)
        }
    }
    
    return line
}

// AlexNet Neural Network layer label'larını oluşturan fonksiyon
func makeAlexNetLayerLabels() -> Entity {
    let anchor = Entity()
    anchor.name = "AlexNetLayerLabelsAnchor"
    
    let layerSpacing: Float = 0.6    // Layer'lar arası mesafe (neuron anchor ile aynı)
    let labelYPosition: Float = -1.0  // Label'ları en alt nöronun altında
    
    // Layer sayıları
    let layerCounts = ["1000", "4096", "4096", "9216"]
    
    // 4 layer için label'lar
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
        
        // Label pozisyonu - layer'ın tam altında
        let x = Float(layerIndex) * layerSpacing
        textEntity.position = SIMD3<Float>(x + 0.08, labelYPosition, 0)  // -0.08 offset text merkezlemek için
        
        // Label'ları kullanıcıya dönecek şekilde 180° döndür (ağ modeli arkada olduğu için)
        textEntity.transform.rotation = simd_quatf(angle: Float.pi, axis: SIMD3<Float>(0, 1, 0))
        
        anchor.addChild(textEntity)
    }
    
    return anchor
}
