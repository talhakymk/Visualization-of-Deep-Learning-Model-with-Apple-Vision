//
//  AppModel.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 26.08.2025.
//

import SwiftUI

/// Maintains app-wide state - Updated for Feature Map Detail Panel
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "StaticPanelSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    // Model that will shown depends on button press
    enum SelectedModel {
        case lenet
        case alexnet
    }
    var selectedModel: SelectedModel? = nil {
        didSet {
            // Model değiştiğinde tüm feature map panellerini kapat
            if selectedModel != oldValue {
                closeAllFeatureMapDetailPanels()
            }
        }
    }
    
    var selectedInputImageName: String? = nil
    
    // Current input index for output visualization (0-9)
    var currentInputIndex: Int = 0
    
    // Açık küpler için set (0..3 LeNet, 0..7 AlexNet). Her küp için ayrı galeri gösterilebilir
    var openCubeIndices: Set<Int> = []
    
    // AlexNet açık küpler için ayrı set (0..7)
    var openAlexNetCubeIndices: Set<Int> = []
    
    // Bağlantı görselleştirme state'i - Multi-layer support
    var activeConnections: Set<String> = [] // "flatten_12" veya "dense1_45" formatında
    var selectedNeuronLayer: String? = nil // "flatten", "dense1", "dense2"
    var selectedNeuronIndex: Int? = nil // 0-255 (flatten), 0-119 (dense1), 0-83 (dense2)
    
    // Multi-layer neuron selections - Her layer'da ayrı seçim
    var selectedNeurons: [String: Int] = [:] // "flatten" → 42, "dense1" → 18, etc.
    
    // Multiple Feature Map Detail Panels State
    var openFeatureMapPanels: [(id: UUID, cubeIndex: Int, featureMapIndex: Int)] = []
    
    // Seçili input'tan rakamı çıkart (input_0 → 0). Yoksa currentInputIndex döner.
    func selectedInputIndex() -> Int? {
        guard let name = selectedInputImageName else { return currentInputIndex }
        if name.hasPrefix("input_") {
            let suffix = name.dropFirst("input_".count)
            if let index = Int(suffix) {
                currentInputIndex = index
                return index
            }
        }
        return currentInputIndex
    }
    
    // Belirli bir küp için gösterilecek görsel adlarını ve grid bilgisini üret (yalnızca LeNet).
    func lenetFeatureMapConfigForCube(_ cubeIndex: Int) -> (images: [String], columns: Int, rows: Int)? {
        guard selectedModel == .lenet, let inputIdx = selectedInputIndex() else {
            return nil
        }
        
        let result: (images: [String], columns: Int, rows: Int)?
        switch cubeIndex {
        case 0:
            let names = (0..<6).map { "\(inputIdx)_lenet_conv_6_featmap_\($0)" }
            result = (names, 3, 2)
        case 1:
            let names = (0..<16).map { "\(inputIdx)_lenet_conv_16_featmap_\($0)" }
            result = (names, 4, 4)
        case 2:
            let names = (0..<6).map { "\(inputIdx)_lenet_maxp_6_featmap_\($0)" }
            result = (names, 3, 2)
        case 3:
            let names = (0..<16).map { "\(inputIdx)_lenet_maxp_16_featmap_\($0)" }
            result = (names, 4, 4)
        default:
            result = nil
        }
        
        return result
    }
    
    // Bir küpün açık olup olmadığını kontrol et (LeNet)
    func isCubeOpen(_ cubeIndex: Int) -> Bool {
        return openCubeIndices.contains(cubeIndex)
    }
    
    // AlexNet küpün açık olup olmadığını kontrol et
    func isAlexNetCubeOpen(_ cubeIndex: Int) -> Bool {
        return openAlexNetCubeIndices.contains(cubeIndex)
    }
    
    // Küp durumunu değiştir (açık/kapalı) - LeNet
    func toggleCube(_ cubeIndex: Int) {
        if openCubeIndices.contains(cubeIndex) {
            openCubeIndices.remove(cubeIndex)
        } else {
            openCubeIndices.insert(cubeIndex)
        }
    }
    
    // AlexNet küp durumunu değiştir (açık/kapalı)
    func toggleAlexNetCube(_ cubeIndex: Int) {
        if openAlexNetCubeIndices.contains(cubeIndex) {
            openAlexNetCubeIndices.remove(cubeIndex)
        } else {
            openAlexNetCubeIndices.insert(cubeIndex)
        }
    }
    
    // Multi-layer nöron seçimi ve bağlantı yönetimi
    func selectNeuron(layer: String, index: Int) {
        // Aynı layer'da aynı nöron tekrar seçilirse deselect et
        if selectedNeurons[layer] == index {
            selectedNeurons.removeValue(forKey: layer)
            // O layer'ın bağlantılarını kaldır ama diğerlerini koru
            removeConnectionsForLayer(layer)
        } else {
            // O layer'da yeni nöron seç (önceki layer selection'ını replace et)
            selectedNeurons[layer] = index
            // O layer için yeni bağlantılar oluştur
            generateConnections(for: layer, neuronIndex: index)
        }
        
        // En son seçilen layer'ı track et (UI feedback için)
        selectedNeuronLayer = layer
        selectedNeuronIndex = index
    }
    
    func clearConnections() {
        selectedNeuronLayer = nil
        selectedNeuronIndex = nil
        selectedNeurons.removeAll()
        activeConnections.removeAll()
    }
    
    // Belirli bir layer'ın bağlantılarını kaldır
    private func removeConnectionsForLayer(_ layer: String) {
        let connectionsToRemove = activeConnections.filter { connectionId in
            connectionId.hasPrefix("\(layer)") // "flatten12_to_dense145" → flatten ile başlayanlar
        }
        for connectionId in connectionsToRemove {
            activeConnections.remove(connectionId)
        }
    }
    
    private func generateConnections(for layer: String, neuronIndex: Int) {
        // Sadece bu layer'ın eski bağlantılarını kaldır (tümünü değil!)
        removeConnectionsForLayer(layer)
        
        switch layer {
        case "flatten":
            // Flatten'dan Dense1'e bağlantılar - 50 adet (performans optimizasyonu)
            // 120 yerine 50: her 2.4. nöron (~her 2-3. nöron)
            let step = 120.0 / 50.0 // 2.4
            for i in 0..<50 {
                let targetIndex = Int(Double(i) * step)
                activeConnections.insert("flatten\(neuronIndex)_to_dense1\(targetIndex)")
            }
            
        case "dense1":
            // Dense1'den Dense2'ye bağlantılar - 30 adet (performans optimizasyonu)
            // 84 yerine 30: her 2.8. nöron (~her 3. nöron)
            let step = 84.0 / 30.0 // 2.8
            for i in 0..<30 {
                let targetIndex = Int(Double(i) * step)
                activeConnections.insert("dense1\(neuronIndex)_to_dense2\(targetIndex)")
            }
            
        case "dense2":
            // Dense2'den Output'a bağlantılar - 6 adet (10 output'tan sadece 6 tanesini göster)
            // 10 yerine 6: her 1.67. nöron (~her 1-2. nöron)
            let step = 10.0 / 6.0 // 1.67
            for i in 0..<6 {
                let targetIndex = Int(Double(i) * step)
                activeConnections.insert("dense2\(neuronIndex)_to_output\(targetIndex)")
            }
            
        default:
            break
        }
    }
    
    // Multiple Feature Map Detail Panel Functions
    func openFeatureMapDetailPanel(cubeIndex: Int, featureMapIndex: Int) {
        // Aynı cube ve feature map için zaten açık panel var mı kontrol et
        let exists = openFeatureMapPanels.contains { panel in
            panel.cubeIndex == cubeIndex && panel.featureMapIndex == featureMapIndex
        }
        
        // Yoksa yeni panel ekle
        if !exists {
            let newPanel = (id: UUID(), cubeIndex: cubeIndex, featureMapIndex: featureMapIndex)
            openFeatureMapPanels.append(newPanel)
        }
    }
    
    func closeFeatureMapDetailPanel(id: UUID) {
        openFeatureMapPanels.removeAll { $0.id == id }
    }
    
    func closeAllFeatureMapDetailPanels() {
        print("Closing all feature map panels. Current count: \(openFeatureMapPanels.count)")
        openFeatureMapPanels.removeAll()
    }
}
