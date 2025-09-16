//
//  AppModel.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 26.08.2025.
//

import SwiftUI

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
    
    // Modeller
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
    
    var selectedInputImageName: String? = nil {
        didSet {
            // Input değiştiğinde tüm küpleri ve panelleri otomatik kapat
            if selectedInputImageName != oldValue {
                closeAllCubesAndPanels()
            }
        }
    }
    
    // Lenet için seçilen input indexi
    var currentInputIndex: Int = 0
    
    // Açık küpler için set
    var openCubeIndices: Set<Int> = []
    
    // AlexNet açık küpler için ayrı set
    var openAlexNetCubeIndices: Set<Int> = []
    
    // AlexNet gallery yükleme halksaı seti
    var loadingAlexNetGalleries: Set<Int> = []
    
    // Lenet için layerlar arası çizgiler
    var activeConnections: Set<String> = []
    var selectedNeuronLayer: String? = nil // "flatten", "dense1", "dense2"
    var selectedNeuronIndex: Int? = nil // 0-255 flatten, 0-119 dense1, 0-83 dense2
    
    // Her layer için ayrı seçim
    var selectedNeurons: [String: Int] = [:]
    
    // Birden fazla feature mapi aynı anda açabilmek için
    var openFeatureMapPanels: [(id: UUID, cubeIndex: Int, featureMapIndex: Int)] = []
    
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
    
    // Lenet için input isimlerinin oluşturulması
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
    
    // Bir küpün açık olup olmadığını kontrol et Lenet
    func isCubeOpen(_ cubeIndex: Int) -> Bool {
        return openCubeIndices.contains(cubeIndex)
    }
    
    // Alexnet küpün açık olup olmadığını kontrol et
    func isAlexNetCubeOpen(_ cubeIndex: Int) -> Bool {
        return openAlexNetCubeIndices.contains(cubeIndex)
    }
    
    // Küp durumunu değiştir Lenet
    func toggleCube(_ cubeIndex: Int) {
        if openCubeIndices.contains(cubeIndex) {
            openCubeIndices.remove(cubeIndex)
        } else {
            openCubeIndices.insert(cubeIndex)
        }
    }
    
    // AlexNet küp durumunu değiştir
    func toggleAlexNetCube(_ cubeIndex: Int) {
        if openAlexNetCubeIndices.contains(cubeIndex) {
            // Küp açıksa kapat
            openAlexNetCubeIndices.remove(cubeIndex)
            loadingAlexNetGalleries.remove(cubeIndex)
        } else {
            // Küp kapalıysa aç ve loading başlat
            loadingAlexNetGalleries.insert(cubeIndex)
            
            // Gallery yükleme simülasyonu için gerçekçi gecikme
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 0.1 saniye loading göster
                self.openAlexNetCubeIndices.insert(cubeIndex)
                // Loading bitince loading stateini kaldır
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // 1 saniye gallery load time
                    self.loadingAlexNetGalleries.remove(cubeIndex)
                }
            }
        }
    }
    
    // Alexnet galery loading state kontrolü
    func isAlexNetGalleryLoading(_ cubeIndex: Int) -> Bool {
        return loadingAlexNetGalleries.contains(cubeIndex)
    }
    
    // nöron seçimi ve bağlantı yönetimi Lenetteki layerlar için
    func selectNeuron(layer: String, index: Int) {
        // Aynı layerda aynı nöron tekrar seçilirse kapat
        if selectedNeurons[layer] == index {
            selectedNeurons.removeValue(forKey: layer)
            // Seçilen layerın bağlantılarını kaldır ama diğerlerini koru
            removeConnectionsForLayer(layer)
        } else {
            // Seçilen layerda yeni nöron seç
            selectedNeurons[layer] = index
            // Seçilen layer için yeni bağlantılar oluştur
            generateConnections(for: layer, neuronIndex: index)
        }
        
        // En son seçilen layerın tracki
        selectedNeuronLayer = layer
        selectedNeuronIndex = index
    }
    
    func clearConnections() {
        selectedNeuronLayer = nil
        selectedNeuronIndex = nil
        selectedNeurons.removeAll()
        activeConnections.removeAll()
    }
    
    // Belirli bir layerın bağlantılarını kaldır
    private func removeConnectionsForLayer(_ layer: String) {
        let connectionsToRemove = activeConnections.filter { connectionId in
            connectionId.hasPrefix("\(layer)")
        }
        for connectionId in connectionsToRemove {
            activeConnections.remove(connectionId)
        }
    }
    
    private func generateConnections(for layer: String, neuronIndex: Int) {
        // Sadece bu layerın eski bağlantılarını kaldır
        removeConnectionsForLayer(layer)
        
        switch layer {
        case "flatten":
            let step = 120.0 / 50.0 // 2.4
            for i in 0..<50 {
                let targetIndex = Int(Double(i) * step)
                activeConnections.insert("flatten\(neuronIndex)_to_dense1\(targetIndex)")
            }
            
        case "dense1":
            let step = 84.0 / 30.0 // 2.8
            for i in 0..<30 {
                let targetIndex = Int(Double(i) * step)
                activeConnections.insert("dense1\(neuronIndex)_to_dense2\(targetIndex)")
            }
            
        case "dense2":
            let step = 10.0 / 6.0 // 1.67
            for i in 0..<6 {
                let targetIndex = Int(Double(i) * step)
                activeConnections.insert("dense2\(neuronIndex)_to_output\(targetIndex)")
            }
            
        default:
            break
        }
    }
    
    // Alexnetteki feature mapler için fonksiyonlar
    func openFeatureMapDetailPanel(cubeIndex: Int, featureMapIndex: Int) {
        // Aynı cube ve feature map için zaten açık panel var mı kontrolü
        let exists = openFeatureMapPanels.contains { panel in
            panel.cubeIndex == cubeIndex && panel.featureMapIndex == featureMapIndex
        }
        
        // yeni panel ekle
        if !exists {
            let newPanel = (id: UUID(), cubeIndex: cubeIndex, featureMapIndex: featureMapIndex)
            openFeatureMapPanels.append(newPanel)
        }
    }
    
    func closeFeatureMapDetailPanel(id: UUID) {
        openFeatureMapPanels.removeAll { $0.id == id }
    }
    
    // Input değiştiğinde tüm küpleri ve panelleri kapatak
    func closeAllCubesAndPanels() {
        print("Input changed - closing all cubes and panels")
        
        // Tüm LeNet küplerini kapat
        openCubeIndices.removeAll()
        
        // Tüm AlexNet küplerini kapat  
        openAlexNetCubeIndices.removeAll()
        
        // Tüm AlexNet loading statelerini temizle
        loadingAlexNetGalleries.removeAll()
        
        // Tüm feature map detail panellerini kapat
        closeAllFeatureMapDetailPanels()
        
        // Neural network bağlantılarını temizle
        clearConnections()
    }
    
    func closeAllFeatureMapDetailPanels() {
        print("Closing all feature map panels. Current count: \(openFeatureMapPanels.count)")
        openFeatureMapPanels.removeAll()
    }
}
