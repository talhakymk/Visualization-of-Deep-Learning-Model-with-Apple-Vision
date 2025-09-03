//
//  ImmersiveView.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 27.08.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent

// Immersive alan içerisine olanlar
// Lenet: MainPanel, 2x2x6 filtre, 5x5x16 filtre

struct ImmersiveView: View {
    
    @Environment(AppModel.self) private var appModel
    
    @State private var cubeTapSubscription: EventSubscription? = nil
    @State private var shrunkCubes: Set<String> = []
    
    var body: some View {
        RealityView { content, attachments in
            if content.entities.isEmpty {
                // 1) Main Panel Anchor
                let mainAnchor = Entity()
                mainAnchor.name = "MainPanelAnchor"
                content.add(mainAnchor)
                // SwiftUI panel entity'sini attachments'tan alıp anchor'a ekle
                if let viewEntity = attachments.entity(for: "mainPanel") {
                    viewEntity.name = "MainPanelAttachmentEntity"
                    mainAnchor.addChild(viewEntity)
                }
                // Panelin sabit konumu (sol-önde, göz hizası civarı)
                var mainT = Transform()
                mainT.translation = SIMD3<Float>(x: -0.6, y: 1.50, z: -1.5)
                mainAnchor.transform = mainT
                
                // 2) 2x2x6 küçük filre
                let smallAnchor = Entity()
                smallAnchor.name = "LenetSmallFiltersAnchor"
                content.add(smallAnchor)
                if let smallEntity = attachments.entity(for: "lenetSmallFilters") {
                    smallEntity.name = "LenetSmallFiltersEntity"
                    smallAnchor.addChild(smallEntity)
                }
                var smallT = Transform()
                smallT.translation = SIMD3<Float>(x: -0.1, y: 2.0, z: -1.5)
                smallAnchor.transform = smallT
                
                // 3) 5x5x16 büyük filtre
                let largeAnchor = Entity()
                largeAnchor.name = "LenetLargeFiltersAnchor"
                content.add(largeAnchor)
                if let largeEntity = attachments.entity(for: "lenetLargeFilters") {
                    largeEntity.name = "LenetLargeFiltersEntity"
                    largeAnchor.addChild(largeEntity)
                }
                var largeT = Transform()
                largeT.translation = SIMD3<Float>(x: 0.35, y: 2, z: -1.5)
                largeAnchor.transform = largeT
                
                // 4) Lenet Küpleri
                let lenetCubeAnchor = makeLenetCubesAnchor()
                var lenetCubesT = Transform()
                lenetCubesT.translation = SIMD3<Float>(x: 1.2, y: 1.0, z: -1.5)
                lenetCubeAnchor.transform = lenetCubesT
                lenetCubeAnchor.isEnabled = false
                content.add(lenetCubeAnchor)
                
                // 4.5) AlexNet Küpleri
                let alexnetCubeAnchor = makeAlexNetCubesAnchor()
                var alexnetCubesT = Transform()
                alexnetCubesT.translation = SIMD3<Float>(x: 1.2, y: 1.0, z: -1.5)
                alexnetCubeAnchor.transform = alexnetCubesT
                alexnetCubeAnchor.isEnabled = false
                content.add(alexnetCubeAnchor)
                
                // 4.6) AlexNet Neural Network Model (arka-sol küpün solunda)
                let alexnetNetworkAnchor = makeAlexNetNeuralNetworkAnchor()
                var alexnetNetworkT = Transform()
                // Arka-sol küp pozisyonu: x=1.2+(-0.8)=0.4, z=-1.5+2.4=0.9
                // Ağ modelini daha solda konumlandır: x=0.4-1.8=-1.4
                alexnetNetworkT.translation = SIMD3<Float>(x: -2.0, y: 1.2, z: 0.9)
                alexnetNetworkAnchor.transform = alexnetNetworkT
                alexnetNetworkAnchor.isEnabled = false
                content.add(alexnetNetworkAnchor)
                
                // 4.7) AlexNet Neural Network Connection Lines
                let alexnetConnectionsAnchor = makeAlexNetConnectionLines()
                var alexnetConnectionsT = Transform()
                // Nöronlarla aynı pozisyonda
                alexnetConnectionsT.translation = SIMD3<Float>(x: -2.0, y: 1.2, z: 0.9)
                alexnetConnectionsAnchor.transform = alexnetConnectionsT
                alexnetConnectionsAnchor.isEnabled = false
                content.add(alexnetConnectionsAnchor)
                
                // 4.8) AlexNet Neural Network Layer Labels
                let alexnetLabelsAnchor = makeAlexNetLayerLabels()
                var alexnetLabelsT = Transform()
                // Nöronlarla aynı pozisyonda
                alexnetLabelsT.translation = SIMD3<Float>(x: -2.0, y: 1.2, z: 0.9)
                alexnetLabelsAnchor.transform = alexnetLabelsT
                alexnetLabelsAnchor.isEnabled = false
                content.add(alexnetLabelsAnchor)
                
                // 5) Her küp için ayrı Lenet FeatureMap Galerisi anchor'ları
                // Küplerle aynı yatay düzende, küplerin üstünde
                let cubeSpacing: Float = 0.8
                let startX: Float = -((cubeSpacing * 3) / 2.0)
                let galleryYOffset: Float = 0.35  // Küplerin üstünde
                
                for i in 0..<4 {
                    let lenetGalleryAnchor = Entity()
                    lenetGalleryAnchor.name = "LenetFeatureGalleryAnchor_\(i)"
                    var lenetGalleryT = Transform()
                    
                    // Küplerle aynı x pozisyonu, üstte
                    let x = startX + Float(i) * cubeSpacing
                    lenetGalleryT.translation = SIMD3<Float>(x: 1.2 + x, y: 1.0 + galleryYOffset, z: -1.5)
                    lenetGalleryAnchor.transform = lenetGalleryT
                    lenetGalleryAnchor.isEnabled = false
                    content.add(lenetGalleryAnchor)
                }
                
                // 6) Flatten Layer Visualization - Arkada, büyük ve merkezi
                let flattenAnchor = Entity()
                flattenAnchor.name = "FlattenLayerAnchor"
                content.add(flattenAnchor)
                if let flattenEntity = attachments.entity(for: "flattenLayer") {
                    flattenEntity.name = "FlattenLayerEntity"
                    flattenAnchor.addChild(flattenEntity)
                }
                var flattenT = Transform()
                flattenT.translation = SIMD3<Float>(x: 3.5, y: 1.2, z: -1.5) // Küplerden biraz daha uzak
                // flattenT.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) // Rotation kaldırıldı - kullanıcıya baksın
                flattenT.scale = SIMD3<Float>(repeating: 1.2) // Biraz daha küçük
                flattenAnchor.transform = flattenT
                flattenAnchor.isEnabled = false
                
                // 7) Dense Layer 1 Visualization - Flatten'in sağında
                let dense1Anchor = Entity()
                dense1Anchor.name = "Dense1LayerAnchor"
                content.add(dense1Anchor)
                if let dense1Entity = attachments.entity(for: "dense1Layer") {
                    dense1Entity.name = "Dense1LayerEntity"
                    dense1Anchor.addChild(dense1Entity)
                }
                var dense1T = Transform()
                dense1T.translation = SIMD3<Float>(x: 4.4, y: 1.2, z: -1.5) // Flatten'e daha yakın (1m mesafe)
                // dense1T.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) // Rotation kaldırıldı
                dense1T.scale = SIMD3<Float>(repeating: 1.2) // Biraz daha küçük
                dense1Anchor.transform = dense1T
                dense1Anchor.isEnabled = false
                
                // 8) Dense Layer 2 Visualization - Dense1'in sağında
                let dense2Anchor = Entity()
                dense2Anchor.name = "Dense2LayerAnchor"
                content.add(dense2Anchor)
                if let dense2Entity = attachments.entity(for: "dense2Layer") {
                    dense2Entity.name = "Dense2LayerEntity"
                    dense2Anchor.addChild(dense2Entity)
                }
                var dense2T = Transform()
                dense2T.translation = SIMD3<Float>(x: 5.1, y: 1.2, z: -1.5) // Dense1'e çok daha yakın (0.3m mesafe)
                // dense2T.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)) // Rotation kaldırıldı
                dense2T.scale = SIMD3<Float>(repeating: 1.2) // Biraz daha küçük
                dense2Anchor.transform = dense2T
                dense2Anchor.isEnabled = false
                
                // 9) Output Layer Visualization - Dense2'nin sağında (final output)
                let outputAnchor = Entity()
                outputAnchor.name = "OutputLayerAnchor"
                content.add(outputAnchor)
                if let outputEntity = attachments.entity(for: "outputLayer") {
                    outputEntity.name = "OutputLayerEntity"
                    outputAnchor.addChild(outputEntity)
                }
                var outputT = Transform()
                outputT.translation = SIMD3<Float>(x: 5.7, y: 1.2, z: -1.5) // Dense2'nin sağında (0.6m mesafe)
                outputT.scale = SIMD3<Float>(repeating: 1.0) // Normal boyut
                outputAnchor.transform = outputT
                outputAnchor.isEnabled = false
                
                // 10) Connection Lines Container - Nöron bağlantı çizgilerini tutacak
                let connectionAnchor = Entity()
                connectionAnchor.name = "ConnectionLinesAnchor"
                content.add(connectionAnchor)
            }
        } update: { content, attachments in
            // Küpler sadece LeNet + input seçiliyse görünsün
            if let cubes = content.entities.first(where: { $0.name == "LenetCubesAnchor" }) {
                let shouldShowCubes = (appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil)
                cubes.isEnabled = shouldShowCubes
            }
            
            // AlexNet küpler sadece AlexNet + input seçiliyse görünsün
            if let alexnetCubes = content.entities.first(where: { $0.name == "AlexNetCubesAnchor" }) {
                let shouldShowAlexNetCubes = (appModel.selectedModel == .alexnet && appModel.selectedInputImageName != nil)
                alexnetCubes.isEnabled = shouldShowAlexNetCubes
            }
            
            // AlexNet Neural Network sadece AlexNet + input seçiliyse görünsün
            if let alexnetNetwork = content.entities.first(where: { $0.name == "AlexNetNeuralNetworkAnchor" }) {
                let shouldShowAlexNetNetwork = (appModel.selectedModel == .alexnet && appModel.selectedInputImageName != nil)
                alexnetNetwork.isEnabled = shouldShowAlexNetNetwork
            }
            
            // AlexNet Neural Network Connections sadece AlexNet + input seçiliyse görünsün
            if let alexnetConnections = content.entities.first(where: { $0.name == "AlexNetConnectionLinesAnchor" }) {
                let shouldShowAlexNetConnections = (appModel.selectedModel == .alexnet && appModel.selectedInputImageName != nil)
                alexnetConnections.isEnabled = shouldShowAlexNetConnections
            }
            
            // AlexNet Neural Network Layer Labels sadece AlexNet + input seçiliyse görünsün
            if let alexnetLabels = content.entities.first(where: { $0.name == "AlexNetLayerLabelsAnchor" }) {
                let shouldShowAlexNetLabels = (appModel.selectedModel == .alexnet && appModel.selectedInputImageName != nil)
                alexnetLabels.isEnabled = shouldShowAlexNetLabels
            }
            
            // Her küp için ayrı galeri kontrolü
            for i in 0..<4 {
                if let gallery = content.entities.first(where: { $0.name == "LenetFeatureGalleryAnchor_\(i)" }) {
                    let shouldShowGallery = (appModel.selectedModel == .lenet && 
                                           appModel.selectedInputImageName != nil && 
                                           appModel.isCubeOpen(i))
                    gallery.isEnabled = shouldShowGallery
                    
                    // Galeri attachment'ını güncelle
                    if shouldShowGallery {
                        // Eski attachment'ları kaldır
                        gallery.children.removeAll()
                        
                        // Bu küp için attachment oluştur
                        if let galleryEntity = attachments.entity(for: "lenetFeatureGallery_\(i)") {
                            galleryEntity.name = "LenetFeatureGalleryEntity_\(i)"
                            gallery.addChild(galleryEntity)
                        }
                    }
                }
            }
            
            // Flatten Layer: LeNet + input seçili olduğunda göster
            if let flatten = content.entities.first(where: { $0.name == "FlattenLayerAnchor" }) {
                let shouldShowFlatten = (appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil)
                flatten.isEnabled = shouldShowFlatten
                
                // Flatten attachment'ını sadece durumu değiştiğinde güncelle (stability için)
                if shouldShowFlatten && flatten.children.isEmpty {
                    if let flattenEntity = attachments.entity(for: "flattenLayer") {
                        flattenEntity.name = "FlattenLayerEntity"
                        flatten.addChild(flattenEntity)
                    }
                }
            }
            
            // Dense Layer 1: LeNet + input seçili olduğunda göster
            if let dense1 = content.entities.first(where: { $0.name == "Dense1LayerAnchor" }) {
                let shouldShowDense1 = (appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil)
                dense1.isEnabled = shouldShowDense1
                
                // Dense1 attachment'ını sadece durumu değiştiğinde güncelle (stability için)
                if shouldShowDense1 && dense1.children.isEmpty {
                    if let dense1Entity = attachments.entity(for: "dense1Layer") {
                        dense1Entity.name = "Dense1LayerEntity"
                        dense1.addChild(dense1Entity)
                    }
                }
            }
            
            // Dense Layer 2: LeNet + input seçili olduğunda göster
            if let dense2 = content.entities.first(where: { $0.name == "Dense2LayerAnchor" }) {
                let shouldShowDense2 = (appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil)
                dense2.isEnabled = shouldShowDense2
                
                // Dense2 attachment'ını sadece durumu değiştiğinde güncelle (stability için)
                if shouldShowDense2 && dense2.children.isEmpty {
                    if let dense2Entity = attachments.entity(for: "dense2Layer") {
                        dense2Entity.name = "Dense2LayerEntity"
                        dense2.addChild(dense2Entity)
                    }
                }
            }
            
            // Output Layer: LeNet + input seçili olduğunda göster
            if let output = content.entities.first(where: { $0.name == "OutputLayerAnchor" }) {
                let shouldShowOutput = (appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil)
                output.isEnabled = shouldShowOutput
                
                // Output attachment'ını sadece durumu değiştiğinde güncelle (stability için)
                if shouldShowOutput && output.children.isEmpty {
                    if let outputEntity = attachments.entity(for: "outputLayer") {
                        outputEntity.name = "OutputLayerEntity"
                        output.addChild(outputEntity)
                    }
                }
            }
            
            // Connection Lines: Nöron bağlantılarını güncelle (sadece LeNet için)
            if let connectionAnchor = content.entities.first(where: { $0.name == "ConnectionLinesAnchor" }) {
                // Önce mevcut tüm bağlantıları temizle
                connectionAnchor.children.removeAll()
                
                // Sadece LeNet seçiliyse ve aktif bağlantılar varsa çizgileri oluştur
                if appModel.selectedModel == .lenet && 
                   appModel.selectedInputImageName != nil &&
                   !appModel.activeConnections.isEmpty {
                    updateConnectionLines(connectionAnchor: connectionAnchor)
                }
            }
        } attachments: {
            // MainPanel içeriği
            Attachment(id: "mainPanel") {
                MainPanelView()
                    .padding(.horizontal, 24)
                    .frame(width: 600, height: 1700)
                    .background(Color.blue, in: .rect(cornerRadius: 16))
            }
            
            // 2x2x6 panel içeriği
            Attachment(id: "lenetSmallFilters") {
                Group {
                    if appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil{
                        LenetSmallFiltersPanel(onTap: { _ in /* opsiyonel */ })
                    } else {
                        EmptyView()
                    }
                }
            }
            
            // 5x5x16 panel içeriği
            Attachment(id: "lenetLargeFilters") {
                Group {
                    if appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil{
                        LenetLargeFiltersPanel()
                    } else {
                        EmptyView()
                    }
                }
            }
            // Her küp için ayrı Lenet FeatureMap Galerisi
            ForEach(0..<4, id: \.self) { cubeIndex in
                Attachment(id: "lenetFeatureGallery_\(cubeIndex)") {
                    Group {
                        if let cfg = appModel.lenetFeatureMapConfigForCube(cubeIndex), appModel.isCubeOpen(cubeIndex) {
                            LenetFeatureMapGalleryView(images: cfg.images, columns: cfg.columns, rows: cfg.rows)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            
            // Flatten Layer Visualization
            Attachment(id: "flattenLayer") {
                Group {
                    if let inputIndex = appModel.selectedInputIndex() {
                        FlattenVisualizationView(inputIndex: inputIndex)
                    } else {
                        EmptyView()
                    }
                }
            }
            
            // Dense Layer 1 Visualization
            Attachment(id: "dense1Layer") {
                Group {
                    if let inputIndex = appModel.selectedInputIndex() {
                        DenseVisualizationView(
                            inputIndex: inputIndex,
                            layerName: "DENSE LAYER 1",
                            layerType: "dense_1",
                            gridRows: 12,
                            gridCols: 10
                        )
                    } else {
                        EmptyView()
                    }
                }
            }
            
            // Dense Layer 2 Visualization
            Attachment(id: "dense2Layer") {
                Group {
                    if let inputIndex = appModel.selectedInputIndex() {
                        DenseVisualizationView(
                            inputIndex: inputIndex,
                            layerName: "DENSE LAYER 2",
                            layerType: "dense_2",
                            gridRows: 12,
                            gridCols: 7
                        )
                    } else {
                        EmptyView()
                    }
                }
            }
            
            // Output Layer Visualization
            Attachment(id: "outputLayer") {
                OutputVisualizationView(appModel: appModel)
            }
        }
        // dokunulan küplerin küçülmesi
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tapped = value.entity
                    
                    // LeNet küpleri
                    if tapped.name.hasPrefix("LenetCube_") {
                        if let idxStr = tapped.name.split(separator: "_").last, let idx = Int(idxStr) {
                            // Küpün durumunu değiştir (açık/kapalı)
                            appModel.toggleCube(idx)
                            
                            // Küpün görsel durumunu güncelle
                            var t = tapped.transform
                            if appModel.isCubeOpen(idx) {
                                t.scale = SIMD3<Float>(repeating: 0.25)  // küçük (açık)
                                shrunkCubes.insert(tapped.name)
                            } else {
                                t.scale = SIMD3<Float>(repeating: 1.0)   // orijinal (kapalı)
                                shrunkCubes.remove(tapped.name)
                            }
                            tapped.transform = t
                        }
                    }
                    
                    // AlexNet küpleri
                    else if tapped.name.hasPrefix("AlexNetCube_") {
                        if let idxStr = tapped.name.split(separator: "_").last, let idx = Int(idxStr) {
                            // Küpün durumunu değiştir (açık/kapalı)
                            appModel.toggleAlexNetCube(idx)
                            
                            // Küpün görsel durumunu güncelle
                            var t = tapped.transform
                            if appModel.isAlexNetCubeOpen(idx) {
                                t.scale = SIMD3<Float>(repeating: 0.25)  // küçük (açık)
                                shrunkCubes.insert(tapped.name)
                            } else {
                                t.scale = SIMD3<Float>(repeating: 1.0)   // orijinal (kapalı)
                                shrunkCubes.remove(tapped.name)
                            }
                            tapped.transform = t
                        }
                    }
                }
        )
    }
    
    // Helper function: Connection line'ları oluştur
    private func updateConnectionLines(connectionAnchor: Entity) {
        guard let _ = appModel.selectedNeuronLayer,
              let _ = appModel.selectedNeuronIndex else { return }
        
        // Layer pozisyonları (ImmersiveView'deki pozisyonlarla eşleşmeli)
        let flattenPos = SIMD3<Float>(x: 3.5, y: 1.2, z: -1.5)
        let dense1Pos = SIMD3<Float>(x: 4.4, y: 1.2, z: -1.5)
        let dense2Pos = SIMD3<Float>(x: 5.15, y: 1.2, z: -1.5) // Dense1'e yakın
        let outputPos = SIMD3<Float>(x: 5.85, y: 1.2, z: -1.5)  // Dense2'nin sağında
        
        for connectionId in appModel.activeConnections {
            if let line = createConnectionLine(connectionId: connectionId, 
                                              flattenPos: flattenPos,
                                              dense1Pos: dense1Pos, 
                                              dense2Pos: dense2Pos,
                                              outputPos: outputPos) {
                connectionAnchor.addChild(line)
            }
        }
    }
    
    // Helper function: Sabit motif connection line oluştur
    private func createConnectionLine(connectionId: String, 
                                    flattenPos: SIMD3<Float>,
                                    dense1Pos: SIMD3<Float>, 
                                    dense2Pos: SIMD3<Float>,
                                    outputPos: SIMD3<Float>) -> Entity? {
        
        // Connection ID'yi parse et: "flatten12_to_dense1_fixed" 
        let parts = connectionId.split(separator: "_to_")
        guard parts.count == 2 else { return nil }
        
        let fromPart = String(parts[0]) // "flatten12"
        let toPart = String(parts[1])   // "dense1_fixed"
        
        // From position hesapla (seçilen neuron - gerçek grid position)
        var fromPos = SIMD3<Float>(0, 0, 0)
        var fromNeuronIndex = 0
        
        if fromPart.hasPrefix("flatten") {
            fromNeuronIndex = Int(fromPart.dropFirst("flatten".count)) ?? 0
            fromPos = calculateNeuronPosition(layer: "flatten", neuronIndex: fromNeuronIndex, layerPos: flattenPos)
        } else if fromPart.hasPrefix("dense1") {
            fromNeuronIndex = Int(fromPart.dropFirst("dense1".count)) ?? 0
            fromPos = calculateNeuronPosition(layer: "dense1", neuronIndex: fromNeuronIndex, layerPos: dense1Pos)
        } else if fromPart.hasPrefix("dense2") {
            fromNeuronIndex = Int(fromPart.dropFirst("dense2".count)) ?? 0
            fromPos = calculateNeuronPosition(layer: "dense2", neuronIndex: fromNeuronIndex, layerPos: dense2Pos)
        }
        
        // To position hesapla - SABİT YELPAZE PATTERN (grid pozisyonundan bağımsız)
        var toPos = SIMD3<Float>(0, 0, 0)
        var toNeuronIndex = 0
        
        if toPart.hasPrefix("dense1") {
            toNeuronIndex = Int(toPart.dropFirst("dense1".count)) ?? 0
            // SABİT YELPAZE: dense1 layer center'dan sabit pattern çıkar (flatten→dense1: geniş yelpaze)
            toPos = calculateFixedFanPosition(targetIndex: toNeuronIndex, totalTargets: 120, layerPos: dense1Pos, targetLayer: "dense1")
        } else if toPart.hasPrefix("dense2") {
            toNeuronIndex = Int(toPart.dropFirst("dense2".count)) ?? 0
            // SABİT YELPAZE: dense2 layer center'dan sabit pattern çıkar (dense1→dense2: dar yelpaze)
            toPos = calculateFixedFanPosition(targetIndex: toNeuronIndex, totalTargets: 84, layerPos: dense2Pos, targetLayer: "dense2")
        } else if toPart.hasPrefix("output") {
            toNeuronIndex = Int(toPart.dropFirst("output".count)) ?? 0
            // SABİT YELPAZE: output layer center'dan sabit pattern çıkar (dense2→output: çok dar yelpaze, 10 output)
            toPos = calculateFixedFanPosition(targetIndex: toNeuronIndex, totalTargets: 10, layerPos: outputPos, targetLayer: "output")
        }
        
        // Çizgi entity'si oluştur
        return createLineBetweenPoints(from: fromPos, to: toPos, connectionId: connectionId)
    }
    
    // Helper function: Nöron pozisyonunu hesapla (layer içindeki grid pozisyonu)
    private func calculateNeuronPosition(layer: String, neuronIndex: Int, layerPos: SIMD3<Float>) -> SIMD3<Float> {
        var neuronPos = layerPos
        
        // Grid boyutları
        let (rows, cols) = getLayerGridDimensions(layer: layer)
        
        // Nöron index'ten row/col hesapla
        let row = neuronIndex / cols
        let col = neuronIndex % cols
        
        // SwiftUI'da 700 points, scale factor güncellenmiş
        let baseImageSize: Float = 0.47  // Çok daha küçük base size (debug için)
        let scaleFactor: Float = 1.2    // Scale factor azalt (1.2 → 1.0)
        let actualImageSize = baseImageSize * scaleFactor
        
        // Dense layer'lar için aspect ratio düzeltmesi
        var actualWidth = actualImageSize
        var actualHeight = actualImageSize
        
        if layer.hasPrefix("dense") {
            let aspectRatio = Float(cols) / Float(rows)
            if aspectRatio > 1 {
                // Daha geniş (landscape)
                actualHeight = actualImageSize / aspectRatio
            } else {
                // Daha dar (portrait)  
                actualWidth = actualImageSize * aspectRatio
            }
        }
        
        let cellWidth = actualWidth / Float(cols)
        let cellHeight = actualHeight / Float(rows)
        
        // Grid offset hesapla - EXACT cell center mapping
        // Problem: SwiftUI grid (0,0) = top-left corner, ama biz center istiyoruz
        
        // Cell center offset hesapla: cell'in left-edge'inden center'ına
        let cellCenterOffsetX = cellWidth / 2.0
        let cellCenterOffsetY = cellHeight / 2.0
        
        // Grid'in sol-üst köşesinden offset hesapla
        let gridLeftEdge = -actualWidth / 2.0   // Grid'in sol kenarı
        let gridTopEdge = actualHeight / 2.0    // Grid'in üst kenarı
        
        // Seçilen cell'in center pozisyonunu hesapla
        let cellCenterX = gridLeftEdge + (Float(col) * cellWidth) + cellCenterOffsetX
        let cellCenterY = gridTopEdge - (Float(row) * cellHeight) - cellCenterOffsetY
        
        // Direct absolute position kullan (relative offset değil)
        neuronPos.x += cellCenterX
        neuronPos.y += cellCenterY
        
        return neuronPos
    }
    
    // Helper function: Compact neuron position (dar yelpaze için)
    private func calculateCompactNeuronPosition(layer: String, neuronIndex: Int, layerPos: SIMD3<Float>, scale: Float) -> SIMD3<Float> {
        var neuronPos = layerPos
        
        // Grid boyutları
        let (rows, cols) = getLayerGridDimensions(layer: layer)
        
        // Nöron index'ten row/col hesapla
        let row = neuronIndex / cols
        let col = neuronIndex % cols
        
        // Compact size - çok daha küçük alan (dar yelpaze için)
        let baseImageSize: Float = 0.3 * scale  // Scale factor ile dar yelpaze
        let scaleFactor: Float = 1.0
        let actualImageSize = baseImageSize * scaleFactor
        
        // Dense layer'lar için aspect ratio düzeltmesi
        var actualWidth = actualImageSize
        var actualHeight = actualImageSize
        
        if layer.hasPrefix("dense") {
            let aspectRatio = Float(cols) / Float(rows)
            if aspectRatio > 1 {
                // Landscape: height küçült
                actualHeight = actualImageSize / aspectRatio
            } else {
                // Portrait: width küçült
                actualWidth = actualImageSize * aspectRatio
            }
        }
        
        let cellWidth = actualWidth / Float(cols)
        let cellHeight = actualHeight / Float(rows)
        
        // Compact grid offset hesapla
        let gridLeftEdge = -actualWidth / 2.0
        let gridTopEdge = actualHeight / 2.0
        
        let cellCenterOffsetX = cellWidth / 2.0
        let cellCenterOffsetY = cellHeight / 2.0
        
        let cellCenterX = gridLeftEdge + (Float(col) * cellWidth) + cellCenterOffsetX
        let cellCenterY = gridTopEdge - (Float(row) * cellHeight) - cellCenterOffsetY
        
        // Compact position
        neuronPos.x += cellCenterX
        neuronPos.y += cellCenterY
        
        return neuronPos
    }
    
    // Helper function: SABİT YELPAZE pozisyonu (hangi grid seçerse seçsin aynı pattern)
    private func calculateFixedFanPosition(targetIndex: Int, totalTargets: Int, layerPos: SIMD3<Float>, targetLayer: String) -> SIMD3<Float> {
        var fanPos = layerPos
        
        // Layer'a göre farklı yelpaze parametreleri
        let fanHeight: Float
        if targetLayer == "dense1" {
            // Flatten → Dense1: Geniş yelpaze
            fanHeight = 0.45
        } else if targetLayer == "dense2" {
            // Dense1 → Dense2: Dar yelpaze
            fanHeight = 0.3
        } else if targetLayer == "output" {
            // Dense2 → Output: Çok dar yelpaze (sadece 10 output)
            fanHeight = 0.15
        } else {
            // Default
            fanHeight = 0.5
        }
        
        let fanDistance: Float = -0.2  // Layer'ın önüne (negatif = sol tarafa)
        
        // Target index'i normalize et (0.0 - 1.0 arasında)
        let normalizedIndex = Float(targetIndex) / Float(totalTargets - 1)
        
        // Sabit yelpaze pattern hesapla (layer center'dan)
        let fanX = fanDistance  // Sol tarafa doğru (layer'ın önü)
        let fanY = (normalizedIndex - 0.5) * fanHeight  // -fanHeight/2 den +fanHeight/2 ye
        
        // Sabit pattern uygula
        fanPos.x += fanX
        fanPos.y += fanY
        
        return fanPos
    }
    
    // Helper function: Layer grid boyutlarını döndür
    private func getLayerGridDimensions(layer: String) -> (rows: Int, cols: Int) {
        switch layer {
        case "flatten":
            return (16, 16) // 256 neurons
        case "dense1":
            return (12, 10) // 120 neurons
        case "dense2":
            return (12, 7)  // 84 neurons
        default:
            return (1, 1)
        }
    }
    
    // Helper function: 2D Line (Ultra-thin Box) - Hedef layer'a ulaşan çizgiler
    private func createLineBetweenPoints(from: SIMD3<Float>, to: SIMD3<Float>, connectionId: String) -> Entity {
        let lineEntity = Entity()
        lineEntity.name = "ConnectionLine_\(connectionId)"
        
        // Gerçek mesafeyi hesapla (from → to arası tam uzunluk)
        let realDistance = distance(from, to)
        let lineThickness: Float = 0.0002  // Biraz daha kalın (görünür olsun)
        
        // Ultra-thin box mesh (gerçek uzunlukta line)
        let boxMesh = MeshResource.generateBox(
            width: lineThickness,     // X: ince
            height: lineThickness,    // Y: ince  
            depth: realDistance      // Z: gerçek from→to mesafesi
        )
        
        // Material (2D line görünümü)
        var material = UnlitMaterial(color: .cyan)
        material.blending = .transparent(opacity: 0.9) // Daha görünür
        
        // Model component ekle
        lineEntity.components.set(ModelComponent(mesh: boxMesh, materials: [material]))
        
        // Pozisyon: from ve to noktaları arasındaki tam orta nokta
        let midPoint = (from + to) / 2
        lineEntity.position = midPoint
        
        // Orientation: Box Z-axis'ini from→to direction'ına align et
        let direction = normalize(to - from)
        let quaternion = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: direction)
        lineEntity.orientation = quaternion
        
        return lineEntity
    }
}

    
#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
