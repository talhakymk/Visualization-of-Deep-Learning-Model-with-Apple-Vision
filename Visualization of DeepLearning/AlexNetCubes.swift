//
//  AlexNetCubes.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 03.09.2025.
//

import Foundation
import RealityKit
import UIKit

func makeAlexNetCubesAnchor(labels: [String] = [
    "CONVOLUTION1\n55x55x64", 
    "MAXPOOL1\n27x27x64", 
    "CONVOLUTION2\n27x27x192",
    "MAXPOOL2\n13x13x192",
    "CONVOLUTION3\n13x13x384",
    "CONVOLUTION4\n13x13x256",
    "CONVOLUTION4\n13x13x256",
    "MAXPOOL3\n6x6x256"
]) -> Entity {
    let anchor = Entity()
    anchor.name = "AlexNetCubesAnchor"
    
    let cubeSize: Float = 0.2
    
    // AlexNet için farklı renk paleti (turuncu-kırmızı tonları)
    let cubeColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0),   // Turuncu
        UIColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0),   // Koyu turuncu
        UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0),   // Turuncu-kırmızı
        UIColor(red: 0.8, green: 0.2, blue: 0.3, alpha: 1.0),   // Kırmızı
        UIColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 1.0),   // Altın turuncu
        UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 1.0),   // Pembe-turuncu
        UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0),   // Kahverengi-turuncu
        UIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 1.0)    // Koyu kırmızı
    ]
    
    // 8 küpü 3 grupta yerleştir:
    // Grup 1: Önde 3 küp (0, 1, 2) - rotasyon yok
    // Grup 2: Sağda 2 küp (3, 4) - 90° döndür (kullanıcıya baksın)
    // Grup 3: Arkada 3 küp (5, 6, 7) - 180° döndür (kullanıcıya baksın)
    
    let positions: [SIMD3<Float>] = [
        // Önde 3 küp (kullanıcının önünde, main panel sağında) - mesafeleri arttırıldı
        SIMD3<Float>(-1.2, 0, 0),    // Sol (daha uzak)
        SIMD3<Float>(0, 0, 0),       // Orta
        SIMD3<Float>(1.2, 0, 0),     // Sağ (daha uzak)
        
        // Sağda 2 küp (kullanıcının sağında) - mesafeleri arttırıldı
        SIMD3<Float>(2.4, 0, 1.2),  // Sağ-ön (daha uzak)
        SIMD3<Float>(2.4, 0, 2.4),   // Sağ-arka (daha uzak)
        
        // Arkada 3 küp (kullanıcının arkasında) - mesafeleri arttırıldı
        SIMD3<Float>(-1.2, 0, 3.6),  // Arka-sol (daha uzak)
        SIMD3<Float>(0, 0, 3.6),     // Arka-orta (daha uzak)
        SIMD3<Float>(1.2, 0, 3.6)    // Arka-sağ (daha uzak)
    ]
    
    // Her grup için rotasyon (Y-ekseni etrafında)
    let rotations: [Float] = [
        0, 0, 0,        // Önde 3 küp - rotasyon yok
        90, 90,         // Sağda 2 küp - 90° (kullanıcıya baksın)
        180, 180, 180   // Arkada 3 küp - 180° (kullanıcıya baksın)
    ]
    
    for i in 0..<8 {
        // Mesh ve metalik material
        let mesh = MeshResource.generateBox(size: cubeSize)
        var material = SimpleMaterial()
        material.color = .init(tint: cubeColors[i], texture: nil)
        material.metallic = .float(0.8)        // Metalik parlaklık
        material.roughness = .float(0.2)       // Düşük pürüzlülük (daha parlak)
        
        let cube = ModelEntity(mesh: mesh, materials: [material])
        cube.name = "AlexNetCube_\(i)"
        
        // Tıklanabilirlik
        cube.components.set(CollisionComponent(shapes: [.generateBox(size: [cubeSize, cubeSize, cubeSize])]))
        cube.components.set(InputTargetComponent())
        cube.components.set(HoverEffectComponent())
        
        // Küpleri konumlandır ve döndür
        cube.position = positions[i]
        
        // Y-ekseni etrafında rotasyon uygula
        let rotationAngle = rotations[i] * Float.pi / 180.0  // Dereceyi radyana çevir
        cube.transform.rotation = simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0))
        
        // Label ekle
        let labelText = labels[i]
        let textMesh = MeshResource.generateText(
            labelText,
            extrusionDepth: 0.001,
            font: UIFont.systemFont(ofSize: 0.04, weight: .semibold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        // Metin materyali
        let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.name = "AlexNetCubeLabel_\(i)"
        
        // Label'ı küpün altına yerleştir ve rotasyona göre ayarla
        let yBelow = -(cubeSize / 2.0) - 0.06 - 0.2
        
        // Rotasyona göre label pozisyonunu ayarla
        var labelX = positions[i].x - 0.16
        var labelZ = positions[i].z
        
        // Sağdaki küpler (90°) için label pozisyonunu ayarla
        if rotations[i] == 90 {
            // Küpün tam altında olsun (x sabit), kullanıcıya dönük olsun (z ön tarafta)
            labelX = positions[i].x
            labelZ = positions[i].z - 0.15 // Kullanıcıya doğru (pozitif z yönü) - daha uzak
        }
        // Arkadaki küpler (180°) için label pozisyonunu ayarla
        else if rotations[i] == 180 {
            labelX = positions[i].x + 0.20 // Daha uzak offset
            labelZ = positions[i].z
        }
        
        textEntity.position = SIMD3<Float>(labelX, yBelow, labelZ)
        
        // Sağdaki küpler için özel rotasyon (label'ı kullanıcıya döndür)
        if rotations[i] == 90 {
            // Label'ı kullanıcıya dönecek şekilde rotasyonunu ayarla (-90° yaparak kullanıcıya çevir)
            textEntity.transform.rotation = simd_quatf(angle: -rotationAngle, axis: SIMD3<Float>(0, 1, 0))
        } else {
            // Diğer label'lar küplerle aynı rotasyonda
            textEntity.transform.rotation = simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0))
        }
        
        anchor.addChild(textEntity)
        
        anchor.addChild(cube)
    }
    
    return anchor
}
