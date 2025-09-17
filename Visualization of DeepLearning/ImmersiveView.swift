//
//  ImmersiveView.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 27.08.2025.
//

import SwiftUI
import RealityKit
import RealityKitContent



struct ImmersiveView: View {
    
    @Environment(AppModel.self) private var appModel
    
    @State private var cubeTapSubscription: EventSubscription? = nil
    @State private var shrunkCubes: Set<String> = []
    @State private var detailPanelInitialPositions: [String: SIMD3<Float>] = [:]
    
    var body: some View {
        RealityView { content, attachments in
            if content.entities.isEmpty {
                // Setup MainPanel HandPanel
                setupCommonEntities(content, attachments)
                
                // Seçilen modele özel setup
                switch appModel.selectedModel {
                case .lenet:
                    setupLenetEntities(content, attachments)
                case .alexnet:
                    setupAlexNetEntities(content, attachments)
                case .none:
                    break
                }
            }
        } update: { content, attachments in
            // Seçilen modele göre entitylerin oluşturulması
            switch appModel.selectedModel {
            case .lenet:
                // LeNet entityleri yoksa oluştur
                if !content.entities.contains(where: { $0.name == "LenetCubesAnchor" }) {
                    setupLenetEntities(content, attachments)
                }
                // AlexNet entityleri varsa kaldır
                clearAlexNetEntities(content)
                
            case .alexnet:
                // AlexNet entityleri yoksa oluştur 
                let hasAlexNetCubes = content.entities.contains(where: { $0.name == "AlexNetCubesAnchor" })
                let hasAlexNetNetwork = content.entities.contains(where: { $0.name == "AlexNetNeuralNetworkAnchor" })
                let hasAlexNetPrediction = content.entities.contains(where: { $0.name == "AlexNetPredictionPanelAnchor" })
                
                var hasAlexNetConnections = false
                if let networkAnchor = content.entities.first(where: { $0.name == "AlexNetNeuralNetworkAnchor" }) {
                    hasAlexNetConnections = networkAnchor.children.contains(where: { $0.name == "AlexNetConnectionLinesEntity" })
                }
                
                if !hasAlexNetCubes || !hasAlexNetNetwork || !hasAlexNetConnections || !hasAlexNetPrediction {
                    print("Setting up AlexNet entities - cubes: \(hasAlexNetCubes), network: \(hasAlexNetNetwork), connections: \(hasAlexNetConnections), prediction: \(hasAlexNetPrediction)")
                    setupAlexNetEntities(content, attachments)
                    
                    // Setup sonrası kontrol
                    let hasAlexNetCubesAfter = content.entities.contains(where: { $0.name == "AlexNetCubesAnchor" })
                    let hasAlexNetNetworkAfter = content.entities.contains(where: { $0.name == "AlexNetNeuralNetworkAnchor" })
                    let hasAlexNetPredictionAfter = content.entities.contains(where: { $0.name == "AlexNetPredictionPanelAnchor" })
                    var hasAlexNetConnectionsAfter = false
                    if let networkAnchor = content.entities.first(where: { $0.name == "AlexNetNeuralNetworkAnchor" }) {
                        hasAlexNetConnectionsAfter = networkAnchor.children.contains(where: { $0.name == "AlexNetConnectionLinesEntity" })
                    }
                    print("After setup - cubes: \(hasAlexNetCubesAfter), network: \(hasAlexNetNetworkAfter), connections: \(hasAlexNetConnectionsAfter), prediction: \(hasAlexNetPredictionAfter)")
                }
                // LeNet entityleri varsa kaldır
                clearLenetEntities(content)
                
            case .none:
                // Hiçbir model seçili değilse tüm entityleri kaldır
                clearLenetEntities(content)
                clearAlexNetEntities(content)
            }
            
            // Main Panel her zaman göster ama sadece durumu değiştiğinde güncelle
            if let mainPanelAnchor = content.entities.first(where: { $0.name == "MainPanelAnchor" }) {
                mainPanelAnchor.isEnabled = true // Her zaman aktif
                
                // Main panel attachmentını sadece boşsa ekle
                if mainPanelAnchor.children.isEmpty {
                    if let mainPanelEntity = attachments.entity(for: "mainPanel") {
                        mainPanelEntity.name = "MainPanelAttachmentEntity"
                        mainPanelAnchor.addChild(mainPanelEntity)
                    }
                }
            }
            
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
            
            // AlexNet Neural Network ve Connection Lines
            if let alexnetNetwork = content.entities.first(where: { $0.name == "AlexNetNeuralNetworkAnchor" }) {
                let shouldShowAlexNetNetwork = (appModel.selectedModel == .alexnet && appModel.selectedInputImageName != nil)
                alexnetNetwork.isEnabled = shouldShowAlexNetNetwork
                
                // Connection lines entity'yi child olarak kontrol et ve enable et
                if let connectionLinesEntity = alexnetNetwork.children.first(where: { $0.name == "AlexNetConnectionLinesEntity" }) {
                    connectionLinesEntity.isEnabled = shouldShowAlexNetNetwork
                    print("Connection lines entity enabled: \(shouldShowAlexNetNetwork)")
                } else {
                    print("Connection lines entity not found in neural network anchor children")
                }
            }
            
            // AlexNet Neural Network Layer Labels sadece AlexNet + input seçiliyse görünsün
            if let alexnetLabels = content.entities.first(where: { $0.name == "AlexNetLayerLabelsAnchor" }) {
                let shouldShowAlexNetLabels = (appModel.selectedModel == .alexnet && appModel.selectedInputImageName != nil)
                alexnetLabels.isEnabled = shouldShowAlexNetLabels
            }
            
            // AlexNet Prediction Panel sadece AlexNet + input seçiliyse görünsün
            if let alexnetPrediction = content.entities.first(where: { $0.name == "AlexNetPredictionPanelAnchor" }) {
                let shouldShowAlexNetPrediction = (appModel.selectedModel == .alexnet && appModel.selectedInputImageName != nil)
                alexnetPrediction.isEnabled = shouldShowAlexNetPrediction
                
            } else {
                print("AlexNet Prediction Panel anchor not found in content!")
            }
            
            // Her küp için ayrı galeri kontrolü (LeNet)
            for i in 0..<4 {
                if let gallery = content.entities.first(where: { $0.name == "LenetFeatureGalleryAnchor_\(i)" }) {
                    let shouldShowGallery = (appModel.selectedModel == .lenet && 
                                           appModel.selectedInputImageName != nil && 
                                           appModel.isCubeOpen(i))
                    gallery.isEnabled = shouldShowGallery
                    
                    // Galeri attachmentını sadece durumu değiştiğinde güncelle
                    if shouldShowGallery && gallery.children.isEmpty {
                        // Bu küp için attachment oluştur
                        if let galleryEntity = attachments.entity(for: "lenetFeatureGallery_\(i)") {
                            galleryEntity.name = "LenetFeatureGalleryEntity_\(i)"
                            gallery.addChild(galleryEntity)
                        }
                    }
                }
            }
            
            // AlexNet gallery kontrolü LAZY LOADING optimizasyonu
            for i in 0..<8 {
                if let alexnetGallery = content.entities.first(where: { $0.name == "AlexNetFeatureGalleryAnchor_\(i)" }) {
                    let shouldShowAlexNetGallery = (appModel.selectedModel == .alexnet && 
                                                   appModel.selectedInputImageName != nil && 
                                                   appModel.isAlexNetCubeOpen(i))
                    alexnetGallery.isEnabled = shouldShowAlexNetGallery
                    
                    // LAZY LOADING: Attachmentı sadece gerektiğinde ve input seçiliyse ekle
                    if shouldShowAlexNetGallery && alexnetGallery.children.isEmpty {
                        // Bu AlexNet küpü için attachment oluştur Input seçildikten sonra
                        if let alexnetGalleryEntity = attachments.entity(for: "alexnetFeatureGallery_\(i)") {
                            alexnetGalleryEntity.name = "AlexNetFeatureGalleryEntity_\(i)"
                            alexnetGallery.addChild(alexnetGalleryEntity)
                        }
                    }
                    
                    // LAZY CLEANUP: Galeri kapandığında attachmentı kaldır
                    if !shouldShowAlexNetGallery && !alexnetGallery.children.isEmpty {
                        alexnetGallery.children.removeAll()
                    }
                }
            }
            
            // AlexNet Loading kontrolü
            for i in 0..<8 {
                if let loadingAnchor = content.entities.first(where: { $0.name == "AlexNetGalleryLoadingAnchor_\(i)" }) {
                    let shouldShowLoading = (appModel.selectedModel == .alexnet && 
                                           appModel.selectedInputImageName != nil && 
                                           appModel.isAlexNetGalleryLoading(i))
                    loadingAnchor.isEnabled = shouldShowLoading
                    
                    // Loading attachmentını sadece gerektiğinde ekle
                    if shouldShowLoading && loadingAnchor.children.isEmpty {
                        if let loadingEntity = attachments.entity(for: "alexnetGalleryLoading_\(i)") {
                            loadingEntity.name = "AlexNetGalleryLoadingEntity_\(i)"
                            loadingAnchor.addChild(loadingEntity)
                        }
                    }
                    
                    // Loading bitince attachmentı kaldır
                    if !shouldShowLoading && !loadingAnchor.children.isEmpty {
                        loadingAnchor.children.removeAll()
                    }
                }
            }
            
            // Flatten Layer: LeNet + input seçili olduğunda göster
            if let flatten = content.entities.first(where: { $0.name == "FlattenLayerAnchor" }) {
                let shouldShowFlatten = (appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil)
                flatten.isEnabled = shouldShowFlatten
                
                // Flatten attachmentını sadece durumu değiştiğinde güncelle
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
                
                // Dense1 attachmentını sadece durumu değiştiğinde güncelle
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
                
                // Dense2 attachmentını sadece durumu değiştiğinde güncelle
                if shouldShowDense2 && dense2.children.isEmpty {
                    if let dense2Entity = attachments.entity(for: "dense2Layer") {
                        dense2Entity.name = "Dense2LayerEntity"
                        dense2.addChild(dense2Entity)
                    }
                }
            }
            
            // Output Visualization: LeNet + input seçili olduğunda göster
            if let output = content.entities.first(where: { $0.name == "OutputVisualizationAnchor" }) {
                let shouldShowOutput = (appModel.selectedModel == .lenet && appModel.selectedInputImageName != nil)
                output.isEnabled = shouldShowOutput
                
                // Output attachmentını sadece durumu değiştiğinde güncelle
                if shouldShowOutput && output.children.isEmpty {
                    if let outputEntity = attachments.entity(for: "outputLayer") {
                        outputEntity.name = "OutputVisualizationEntity"
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
            
            // Multiple Feature Map Detail Panelleri - Her panel için ayrı yönetim
            let existingPanelAnchors = content.entities.filter { $0.name.hasPrefix("FeatureMapDetailPanelAnchor_") }
            let existingPanelIds = Set(existingPanelAnchors.compactMap { anchor in
                let components = anchor.name.split(separator: "_")
                return components.count >= 2 ? String(components.dropFirst().joined(separator: "_")) : nil
            })
            
            let activePanelIds = Set(appModel.openFeatureMapPanels.map { $0.id.uuidString })
            
            // Gereksiz panel anchorlarını kaldır
            for anchor in existingPanelAnchors {
                let components = anchor.name.split(separator: "_")
                if components.count >= 2 {
                    let panelIdStr = String(components.dropFirst().joined(separator: "_"))
                    if !activePanelIds.contains(panelIdStr) {
                        content.remove(anchor)
                    }
                }
            }
            
            // Eksik panel anchorlarını ekle
            for panel in appModel.openFeatureMapPanels {
                if !existingPanelIds.contains(panel.id.uuidString) {
                    let detailPanelAnchor = Entity()
                    detailPanelAnchor.name = "FeatureMapDetailPanelAnchor_\(panel.id)"
                    
                    // Aynı cubeden olan panellerin indexini hesapla
                    let sameCubePanels = appModel.openFeatureMapPanels.filter { $0.cubeIndex == panel.cubeIndex }
                    let panelIndexInCube = sameCubePanels.firstIndex { $0.id == panel.id } ?? 0
                    
                    // Panel pozisyonunu seçilen cubein grid hizasında konumlandır
                    let panelPosition = calculateDetailPanelPosition(
                        cubeIndex: panel.cubeIndex,
                        panelIndex: panelIndexInCube,
                        totalPanelsForCube: sameCubePanels.count
                    )
                    detailPanelAnchor.position = panelPosition
                    
                    // Panel rotasyonunu cube pozisyonuna göre ayarla
                    let panelRotation = calculateDetailPanelRotation(cubeIndex: panel.cubeIndex)
                    detailPanelAnchor.orientation = panelRotation
                    
                    content.add(detailPanelAnchor)
                }
            }
            
            // Her panel anchor için attachment güncelle
            for panel in appModel.openFeatureMapPanels {
                if let anchor = content.entities.first(where: { $0.name == "FeatureMapDetailPanelAnchor_\(panel.id)" }) {
                    // Attachmentı sadece boşsa ekle
                    if anchor.children.isEmpty {
                        if let detailPanelEntity = attachments.entity(for: "featureMapDetailPanel_\(panel.id)") {
                            detailPanelEntity.name = "FeatureMapDetailPanelEntity_\(panel.id)"
                            
                            // Panele collision ve input components ekle - Sadece close button için
                            let panelSize: Float = 0.6
                            detailPanelEntity.components.set(CollisionComponent(shapes: [.generateBox(size: [panelSize, panelSize * 1.2, 0.01])]))
                            detailPanelEntity.components.set(InputTargetComponent(allowedInputTypes: [.indirect, .direct]))
                            detailPanelEntity.components.set(HoverEffectComponent())
                            
                            // Drag handle için ayrı entity
                            let dragHandleEntity = Entity()
                            dragHandleEntity.name = "DragHandle_\(panel.id)"
                            dragHandleEntity.position = SIMD3<Float>(0, -0.17, 0.01)
                            
                            // Drag handle collision (panelin alt yarısı)
                            let dragHandleWidth: Float = 0.35
                            let dragHandleHeight: Float = 0.12
                            dragHandleEntity.components.set(CollisionComponent(shapes: [.generateBox(size: [dragHandleWidth, dragHandleHeight, 0.02])]))
                            dragHandleEntity.components.set(InputTargetComponent(allowedInputTypes: [.indirect, .direct]))
                            
                            // Close button için ayrı entity (üst sağ köşede)
                            let closeButtonEntity = Entity()
                            closeButtonEntity.name = "CloseButton_\(panel.id)"
                            closeButtonEntity.position = SIMD3<Float>(0.155, 0.2, 0.02) // Üst sağ köşe
                            
                            // Close button collision
                            let closeButtonSize: Float = 0.035
                            closeButtonEntity.components.set(CollisionComponent(shapes: [.generateBox(size: [closeButtonSize, closeButtonSize, 0.03])]))
                            closeButtonEntity.components.set(InputTargetComponent(allowedInputTypes: [.indirect, .direct]))
                            closeButtonEntity.components.set(HoverEffectComponent())
                            
                            detailPanelEntity.addChild(dragHandleEntity)
                            detailPanelEntity.addChild(closeButtonEntity)
                            anchor.addChild(detailPanelEntity)
                        }
                    }
                }
            }
                        
            // Küp scalelerini AppModel stateine göre sync et
            updateCubeScales(content)
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
                        LenetSmallFiltersPanel(onTap: { _ in  })
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
            
            // AlexNet Prediction Panel
            Attachment(id: "alexnetPredictionPanel") {
                AlexNetPredictionPanel(appModel: appModel)
            }
            
            // AlexNet Feature Map Galleryleri Conditional Loading
            ForEach(0..<8, id: \.self) { cubeIndex in
                Attachment(id: "alexnetFeatureGallery_\(cubeIndex)") {
                    Group {
                        // Sadece input seçiliyse ve cube açıksa yükle
                        if appModel.selectedModel == .alexnet,
                           let inputIndex = appModel.selectedInputIndex(),
                           appModel.selectedInputImageName != nil,
                           appModel.isAlexNetCubeOpen(cubeIndex) {
                            AlexNetFeatureMapGalleryView(
                                cubeIndex: cubeIndex, 
                                inputIndex: inputIndex,
                                selectedInputName: appModel.selectedInputImageName
                            ) { cubeIdx, featureMapIdx in
                                // Feature map detail paneli aç
                                appModel.openFeatureMapDetailPanel(
                                    cubeIndex: cubeIdx, 
                                    featureMapIndex: featureMapIdx
                                )
                            }
                        } else {
                            // AlexNet seçili değilse veya input seçili değilse hiçbir şey yükleme
                            EmptyView()
                        }
                    }
                }
            }
            
            // AlexNet Galery Loading
            ForEach(0..<8, id: \.self) { cubeIndex in
                Attachment(id: "alexnetGalleryLoading_\(cubeIndex)") {
                    Group {
                        if appModel.selectedModel == .alexnet,
                           appModel.selectedInputImageName != nil,
                           appModel.isAlexNetGalleryLoading(cubeIndex) {
                            AlexNetGalleryLoadingView(cubeIndex: cubeIndex)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            
            // Floating Windowlar (Alexnetteki)
            ForEach(appModel.openFeatureMapPanels, id: \.id) { panel in
                Attachment(id: "featureMapDetailPanel_\(panel.id)") {
                    FeatureMapDetailPanel(
                        cubeIndex: panel.cubeIndex,
                        featureMapIndex: panel.featureMapIndex,
                        inputIndex: appModel.selectedInputIndex() ?? 0,
                        selectedInputName: appModel.selectedInputImageName
                    ) {
                        appModel.closeFeatureMapDetailPanel(id: panel.id)
                    }
                }
            }
        }
        // dokunulan küplerin küçülmesi + panel işlemleri
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    let tapped = value.entity
                    
                    // Close Button Entity tapped - Direkt panel kapat
                    if tapped.name.hasPrefix("CloseButton_") {
                        let entityName = tapped.name
                        let panelIdStr = String(entityName.dropFirst("CloseButton_".count))
                        if let panelId = UUID(uuidString: panelIdStr) {
                            appModel.closeFeatureMapDetailPanel(id: panelId)
                        }
                        return
                    }
                    
                    // Feature Map Detail Panel tapped - Close button kontrol et
                    if tapped.name.hasPrefix("FeatureMapDetailPanelEntity_") {
                        let entityName = tapped.name
                        let panelIdStr = String(entityName.dropFirst("FeatureMapDetailPanelEntity_".count))
                        
                        // Paneldeki tap positionını kontrol et
                        let tapPosition = value.location3D
                        
                        // Close buttonun panel üst sağında olduğunu varsay
                        if tapPosition.x > 0.2 && tapPosition.y > 0.25 {
                            if let panelId = UUID(uuidString: panelIdStr) {
                                appModel.closeFeatureMapDetailPanel(id: panelId)
                            }
                            return // Exit early to prevent other gesture handling
                        }
                    }
                    
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
        // Multiple Feature Map Detail Panels için drag gesture
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    // Sadece drag handle entitysi için çalış
                    guard value.entity.name.hasPrefix("DragHandle_") else { return }
                    
                    // Panel IDsini drag handledan çıkar
                    let entityName = value.entity.name
                    let panelIdStr = String(entityName.dropFirst("DragHandle_".count))
                    
                    // Panel anchorını bul
                    guard let panelEntity = value.entity.parent,
                          let detailPanelAnchor = panelEntity.parent else { return }
                    
                    // Drag logic
                    if detailPanelInitialPositions[panelIdStr] == nil {
                        detailPanelInitialPositions[panelIdStr] = detailPanelAnchor.transform.translation
                    }
                    guard let initialPos = detailPanelInitialPositions[panelIdStr] else { return }
                    
                    let translation = value.translation3D
                    let sensitivity: Float = 0.001
                    let scaledX = Float(translation.x) * sensitivity
                    let scaledY = -Float(translation.y) * sensitivity
                    let scaledZ = Float(translation.z) * sensitivity
                    
                    let newX = initialPos.x + scaledX
                    let newY = initialPos.y + scaledY
                    let newZ = initialPos.z + scaledZ
                    
                    var newTransform = detailPanelAnchor.transform
                    newTransform.translation = SIMD3<Float>(newX, newY, newZ)
                    
                    // Rotation
                    let userPosition = SIMD3<Float>(0, 1.6, 0)
                    let panelPosition = newTransform.translation
                    let direction = normalize(userPosition - panelPosition)
                    let angle = atan2(direction.x, direction.z)
                    newTransform.rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(0, 1, 0))
                    
                    detailPanelAnchor.transform = newTransform
                }
                .onEnded { value in
                    guard value.entity.name.hasPrefix("DragHandle_") else { return }
                    
                    // Panel IDsini çıkar ve initial positionı temizle
                    let entityName = value.entity.name
                    let panelIdStr = String(entityName.dropFirst("DragHandle_".count))
                    detailPanelInitialPositions.removeValue(forKey: panelIdStr)
                }
        )
        // Model değişiminde entityleri yeniden oluştur
        .onChange(of: appModel.selectedModel) { oldModel, newModel in
            // Eski model entitylerini temizle ve yeni model entitylerini oluştur
            recreateEntitiesForNewModel(oldModel: oldModel, newModel: newModel)
        }
        // Input değişiminde küp scalelerini reset et
        .onChange(of: appModel.selectedInputImageName) { oldInput, newInput in
            // Input değiştiğinde küçük küplerin scaleini reset et
            if oldInput != newInput {
                resetCubeScales()
            }
        }
    }
    
    // Connection line'ları oluştur
    private func updateConnectionLines(connectionAnchor: Entity) {
        guard let _ = appModel.selectedNeuronLayer,
              let _ = appModel.selectedNeuronIndex else { return }
        
        // Layer pozisyonları
        let flattenPos = SIMD3<Float>(x: 3.5, y: 1.2, z: -1.5)
        let dense1Pos = SIMD3<Float>(x: 4.4, y: 1.2, z: -1.5)
        let dense2Pos = SIMD3<Float>(x: 5.15, y: 1.2, z: -1.5)
        let outputPos = SIMD3<Float>(x: 5.85, y: 1.2, z: -1.5)
        
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
    
    // Sabit motif connection line oluştur
    private func createConnectionLine(connectionId: String, 
                                    flattenPos: SIMD3<Float>,
                                    dense1Pos: SIMD3<Float>, 
                                    dense2Pos: SIMD3<Float>,
                                    outputPos: SIMD3<Float>) -> Entity? {
        
        // Connection IDyi parse
        let parts = connectionId.split(separator: "_to_")
        guard parts.count == 2 else { return nil }
        
        let fromPart = String(parts[0])
        let toPart = String(parts[1])
        
        // From position hesapla
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
        
        // To position hesapla
        var toPos = SIMD3<Float>(0, 0, 0)
        var toNeuronIndex = 0
        
        if toPart.hasPrefix("dense1") {
            toNeuronIndex = Int(toPart.dropFirst("dense1".count)) ?? 0
            toPos = calculateFixedFanPosition(targetIndex: toNeuronIndex, totalTargets: 120, layerPos: dense1Pos, targetLayer: "dense1")
        } else if toPart.hasPrefix("dense2") {
            toNeuronIndex = Int(toPart.dropFirst("dense2".count)) ?? 0
            toPos = calculateFixedFanPosition(targetIndex: toNeuronIndex, totalTargets: 84, layerPos: dense2Pos, targetLayer: "dense2")
        } else if toPart.hasPrefix("output") {
            toNeuronIndex = Int(toPart.dropFirst("output".count)) ?? 0
            toPos = calculateFixedFanPosition(targetIndex: toNeuronIndex, totalTargets: 10, layerPos: outputPos, targetLayer: "output")
        }
        
        // Çizgi entitysi oluştur
        return createLineBetweenPoints(from: fromPos, to: toPos, connectionId: connectionId)
    }
    
    // Nöron pozisyonunu hesapla
    private func calculateNeuronPosition(layer: String, neuronIndex: Int, layerPos: SIMD3<Float>) -> SIMD3<Float> {
        var neuronPos = layerPos
        
        // Grid boyutları
        let (rows, cols) = getLayerGridDimensions(layer: layer)
        
        // Nöron indexten row/col hesapla
        let row = neuronIndex / cols
        let col = neuronIndex % cols
        
        let baseImageSize: Float = 0.47
        let scaleFactor: Float = 1.2
        let actualImageSize = baseImageSize * scaleFactor
        
        // Dense layerlar için aspect ratio düzeltmesi
        var actualWidth = actualImageSize
        var actualHeight = actualImageSize
        
        if layer.hasPrefix("dense") {
            let aspectRatio = Float(cols) / Float(rows)
            if aspectRatio > 1 {
                actualHeight = actualImageSize / aspectRatio
            } else {
                actualWidth = actualImageSize * aspectRatio
            }
        }
        
        let cellWidth = actualWidth / Float(cols)
        let cellHeight = actualHeight / Float(rows)
                
        // Cell center offset hesapla
        let cellCenterOffsetX = cellWidth / 2.0
        let cellCenterOffsetY = cellHeight / 2.0
        
        // Gridin sol üst köşesinden offset hesapla
        let gridLeftEdge = -actualWidth / 2.0
        let gridTopEdge = actualHeight / 2.0
        
        // Seçilen cellin center pozisyonunu hesapla
        let cellCenterX = gridLeftEdge + (Float(col) * cellWidth) + cellCenterOffsetX
        let cellCenterY = gridTopEdge - (Float(row) * cellHeight) - cellCenterOffsetY
        
        neuronPos.x += cellCenterX
        neuronPos.y += cellCenterY
        
        return neuronPos
    }
    
    // Compact neuron position
    private func calculateCompactNeuronPosition(layer: String, neuronIndex: Int, layerPos: SIMD3<Float>, scale: Float) -> SIMD3<Float> {
        var neuronPos = layerPos
        
        // Grid boyutları
        let (rows, cols) = getLayerGridDimensions(layer: layer)
        
        let row = neuronIndex / cols
        let col = neuronIndex % cols
        
        let baseImageSize: Float = 0.3 * scale
        let scaleFactor: Float = 1.0
        let actualImageSize = baseImageSize * scaleFactor
        
        var actualWidth = actualImageSize
        var actualHeight = actualImageSize
        
        if layer.hasPrefix("dense") {
            let aspectRatio = Float(cols) / Float(rows)
            if aspectRatio > 1 {
                actualHeight = actualImageSize / aspectRatio
            } else {
                actualWidth = actualImageSize * aspectRatio
            }
        }
        
        let cellWidth = actualWidth / Float(cols)
        let cellHeight = actualHeight / Float(rows)
        
        let gridLeftEdge = -actualWidth / 2.0
        let gridTopEdge = actualHeight / 2.0
        
        let cellCenterOffsetX = cellWidth / 2.0
        let cellCenterOffsetY = cellHeight / 2.0
        
        let cellCenterX = gridLeftEdge + (Float(col) * cellWidth) + cellCenterOffsetX
        let cellCenterY = gridTopEdge - (Float(row) * cellHeight) - cellCenterOffsetY
        
        neuronPos.x += cellCenterX
        neuronPos.y += cellCenterY
        
        return neuronPos
    }
    
    // Yelpaze şekilli çizgiler
    private func calculateFixedFanPosition(targetIndex: Int, totalTargets: Int, layerPos: SIMD3<Float>, targetLayer: String) -> SIMD3<Float> {
        var fanPos = layerPos
        
        let fanHeight: Float
        if targetLayer == "dense1" {
            fanHeight = 0.45
        } else if targetLayer == "dense2" {
            fanHeight = 0.3
        } else if targetLayer == "output" {
            fanHeight = 0.15
        } else {
            fanHeight = 0.5
        }
        
        let fanDistance: Float = -0.2  // Layerın önüne
        
        let normalizedIndex = Float(targetIndex) / Float(totalTargets - 1)
        
        let fanX = fanDistance
        let fanY = (normalizedIndex - 0.5) * fanHeight
        
        fanPos.x += fanX
        fanPos.y += fanY
        
        return fanPos
    }
    
    // Layer grid boyutlarını döndür
    private func getLayerGridDimensions(layer: String) -> (rows: Int, cols: Int) {
        switch layer {
        case "flatten":
            return (16, 16)
        case "dense1":
            return (12, 10)
        case "dense2":
            return (12, 7)
        default:
            return (1, 1)
        }
    }
    
    // 2D Line Alexnetteki küreler arası çizgiler
    private func createLineBetweenPoints(from: SIMD3<Float>, to: SIMD3<Float>, connectionId: String) -> Entity {
        let lineEntity = Entity()
        lineEntity.name = "ConnectionLine_\(connectionId)"
        
        let realDistance = distance(from, to)
        let lineThickness: Float = 0.0002
        
        let boxMesh = MeshResource.generateBox(
            width: lineThickness,
            height: lineThickness,
            depth: realDistance
        )
        
        // Material (2D line görünümü)
        var material = UnlitMaterial(color: .cyan)
        material.blending = .transparent(opacity: 0.9)
        
        // Model component ekle
        lineEntity.components.set(ModelComponent(mesh: boxMesh, materials: [material]))
        
        // Pozisyon: from ve to noktaları arasındaki tam orta nokta
        let midPoint = (from + to) / 2
        lineEntity.position = midPoint
        
        let direction = normalize(to - from)
        let quaternion = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: direction)
        lineEntity.orientation = quaternion
        
        return lineEntity
    }
    
    //  Detail panel pozisyonunu cube pozisyonuna göre hesapla
    private func calculateDetailPanelPosition(cubeIndex: Int, panelIndex: Int, totalPanelsForCube: Int) -> SIMD3<Float> {
        // AlexNet küp pozisyonları
        let alexnetCubePositions: [SIMD3<Float>] = [
            SIMD3<Float>(-1.2, 0, 0),    // conv1
            SIMD3<Float>(0, 0, 0),       // maxp1
            SIMD3<Float>(1.2, 0, 0),     // conv2
            SIMD3<Float>(2.4, 0, 1.2),  // maxp2
            SIMD3<Float>(2.4, 0, 2.4),  // conv3
            SIMD3<Float>(-1.2, 0, 3.6), // conv4
            SIMD3<Float>(0, 0, 3.6),    // conv5
            SIMD3<Float>(1.2, 0, 3.6)   // maxp3
        ]
        
        // Base anchor position (küplerle aynı base)
        let baseAnchorPos = SIMD3<Float>(x: 1.2, y: 1.0, z: -1.5)
        
        // Gallery Y offset (gridlerle aynı yükseklik)
        let alexnetGalleryYOffset: Float = 0.8
        
        // Seçilen cubein pozisyonu
        guard cubeIndex < alexnetCubePositions.count else {
            return SIMD3<Float>(0, baseAnchorPos.y + alexnetGalleryYOffset, -1.5)
        }
        
        let cubeRelativePos = alexnetCubePositions[cubeIndex]
        let galleryAbsolutePos = SIMD3<Float>(
            x: baseAnchorPos.x + cubeRelativePos.x,
            y: baseAnchorPos.y + alexnetGalleryYOffset,
            z: baseAnchorPos.z + cubeRelativePos.z 
        )
        
        // Panel pozisyonu Grid hizasında ve önünde
        let panelYOffset: Float = 0.0   // Grid ile aynı hizda
        
        // Z offseti cube pozisyonuna göre ayarla
        let panelZOffset: Float
        switch cubeIndex {
        case 0, 1, 2: // Ön taraftaki küpler
            panelZOffset = 0.0
        case 3, 4: // Sağ taraftaki küpler
            panelZOffset = -0.5
        case 5, 6, 7: // Arka taraftaki küpler
            panelZOffset = -0.3
        default:
            panelZOffset = -0.5
        }
        
        // Sağdaki küpler (3,4) için X koordinatını sola çek diğerleri için normal pozisyon
        let panelX: Float
        if cubeIndex == 3 || cubeIndex == 4 { // Sağ taraftaki küpler
            let xOffset: Float = -0.2  // Sola çekme miktarı
            panelX = galleryAbsolutePos.x + xOffset
        } else {
            panelX = galleryAbsolutePos.x  // Normal pozisyon
        }
        
        // Tüm floating windowlar aynı konumda oluşsun
        let panelZ = galleryAbsolutePos.z + panelZOffset
        
        return SIMD3<Float>(
            x: panelX,
            y: galleryAbsolutePos.y + panelYOffset,
            z: panelZ
        )
    }
    
    // Detail panel rotasyonunu cube pozisyonuna göre hesapla
    private func calculateDetailPanelRotation(cubeIndex: Int) -> simd_quatf {
        // Cube pozisyonuna göre kullanıcıya dönük rotasyon
        switch cubeIndex {
        case 3, 4: // Sağ taraftaki küpler
            return simd_quatf(angle: -Float.pi / 2, axis: SIMD3<Float>(0, 1, 0))
        case 5, 6, 7: // Arka taraftaki küpler
            return simd_quatf(angle: Float.pi, axis: SIMD3<Float>(0, 1, 0))
        default: // Ön taraftaki küpler
            return simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        }
    }
    
    
    private func setupCommonEntities(_ content: RealityViewContent, _ attachments: RealityViewAttachments) {
        // 1) Main Panel Anchor
        let mainAnchor = Entity()
        mainAnchor.name = "MainPanelAnchor"
        content.add(mainAnchor)
        // Panelin sabit konumu
        var mainT = Transform()
        mainT.translation = SIMD3<Float>(x: -0.6, y: 1.50, z: -1.5)
        mainAnchor.transform = mainT
        
        // 2) Hand Panel
        if let handEntity = attachments.entity(for: "handpanel") {
            let handAnchor = Entity()
            handAnchor.name = "HandPanelAnchor"
            handEntity.name = "HandPanelEntity"
            handAnchor.addChild(handEntity)
            
            // Hand Panel pozisyonu
            var handT = Transform()
            handT.translation = SIMD3<Float>(x: 0, y: 1.0, z: -0.8)
            handAnchor.transform = handT
            
            content.add(handAnchor)
        }
    }
    
    private func setupLenetEntities(_ content: RealityViewContent, _ attachments: RealityViewAttachments) {
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
        
        // 5) Her küp için ayrı Lenet FeatureMap Galerisi anchorları
        // Küplerle aynı yatay düzende küplerin üstünde
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
        
        // 6) Flatten Layer Visualization Arkada büyük ve merkezi
        let flattenAnchor = Entity()
        flattenAnchor.name = "FlattenLayerAnchor"
        content.add(flattenAnchor)
        if let flattenEntity = attachments.entity(for: "flattenLayer") {
            flattenEntity.name = "FlattenLayerEntity"
            flattenAnchor.addChild(flattenEntity)
        }
        var flattenT = Transform()
        flattenT.translation = SIMD3<Float>(x: 3.5, y: 1.2, z: -1.5) // Küplerden biraz daha uzak
        flattenT.scale = SIMD3<Float>(repeating: 1.2) // Biraz daha küçük
        flattenAnchor.transform = flattenT
        flattenAnchor.isEnabled = false
        
        // 7) Dense Layer 1 Visualization  Flattenin sağında
        let dense1Anchor = Entity()
        dense1Anchor.name = "Dense1LayerAnchor"
        content.add(dense1Anchor)
        if let dense1Entity = attachments.entity(for: "dense1Layer") {
            dense1Entity.name = "Dense1LayerEntity"
            dense1Anchor.addChild(dense1Entity)
        }
        var dense1T = Transform()
        dense1T.translation = SIMD3<Float>(x: 4.4, y: 1.2, z: -1.5)
        dense1T.scale = SIMD3<Float>(repeating: 1.2)
        dense1Anchor.transform = dense1T
        dense1Anchor.isEnabled = false
        
        // 8) Dense Layer 2 Visualization Dense1in sağında
        let dense2Anchor = Entity()
        dense2Anchor.name = "Dense2LayerAnchor"
        content.add(dense2Anchor)
        if let dense2Entity = attachments.entity(for: "dense2Layer") {
            dense2Entity.name = "Dense2LayerEntity"
            dense2Anchor.addChild(dense2Entity)
        }
        var dense2T = Transform()
        dense2T.translation = SIMD3<Float>(x: 5.1, y: 1.2, z: -1.5)
        dense2T.scale = SIMD3<Float>(repeating: 1.2)
        dense2Anchor.transform = dense2T
        dense2Anchor.isEnabled = false
        
        // 9) Output Visualization Panel  Dense2nin sağında
        let outputAnchor = Entity()
        outputAnchor.name = "OutputVisualizationAnchor"
        content.add(outputAnchor)
        if let outputEntity = attachments.entity(for: "outputLayer") {
            outputEntity.name = "OutputVisualizationEntity"
            outputAnchor.addChild(outputEntity)
        }
        var outputT = Transform()
        outputT.translation = SIMD3<Float>(x: 5.8, y: 1.2, z: -1.5) // Dense2nin sağında
        outputT.scale = SIMD3<Float>(repeating: 1.2)
        outputAnchor.transform = outputT
        outputAnchor.isEnabled = false
        
        // 10) Neural Network Connection Lines Anchor
        let connectionLinesAnchor = Entity()
        connectionLinesAnchor.name = "ConnectionLinesAnchor"
        var connectionT = Transform()
        connectionT.translation = SIMD3<Float>(x: 0, y: 0, z: 0) // LeNet cube'larıyla aynı pozisyon
        connectionLinesAnchor.transform = connectionT
        content.add(connectionLinesAnchor)
    }
    
    private func makeAlexNetConnectionLinesEntity() -> Entity {
        let connectionLinesEntity = Entity()
        connectionLinesEntity.name = "AlexNetConnectionLinesEntity"
        
        // makeAlexNetConnectionLines fonksiyonunu doğrudan çağır
        let connectionLinesAnchor = makeAlexNetConnectionLines()
        
        // Childrenı önce arraye kopyala 
        let childrenArray = Array(connectionLinesAnchor.children)
        
        // Connection lines anchorının tüm childrenını entityye ekle
        for child in childrenArray {
            connectionLinesEntity.addChild(child)
        }
        
        print("Connection lines entity created with \(childrenArray.count) lines")
        return connectionLinesEntity
    }
    
    private func setupAlexNetEntities(_ content: RealityViewContent, _ attachments: RealityViewAttachments) {
        // 4.5) AlexNet Küpleri
        let alexnetCubeAnchor = makeAlexNetCubesAnchor()
        var alexnetCubesT = Transform()
        alexnetCubesT.translation = SIMD3<Float>(x: 1.2, y: 1.0, z: -1.5)
        alexnetCubeAnchor.transform = alexnetCubesT
        alexnetCubeAnchor.isEnabled = false
        content.add(alexnetCubeAnchor)
        
        // 4.6) AlexNet Neural Network Model
        let alexnetNetworkAnchor = makeAlexNetNeuralNetworkAnchor()
        var alexnetNetworkT = Transform()
        alexnetNetworkT.translation = SIMD3<Float>(x: -2.5, y: 1.2, z: 2.1)
        alexnetNetworkAnchor.transform = alexnetNetworkT
        alexnetNetworkAnchor.isEnabled = false
        content.add(alexnetNetworkAnchor)
        
        // 4.7) AlexNet Neural Network Connection Lines - CHILD APPROACH
        print("Creating AlexNet connection lines as child")
        
        // Connection lines'ları neural network anchor'ının child'ı olarak ekle
        let connectionLinesEntity = makeAlexNetConnectionLinesEntity()
        connectionLinesEntity.name = "AlexNetConnectionLinesEntity"
        connectionLinesEntity.transform = Transform() // Relative transform
        alexnetNetworkAnchor.addChild(connectionLinesEntity)
        print("Connection lines added as child to neural network anchor")
        
        // VERIFY ADD WORKED
        if let networkAnchor = content.entities.first(where: { $0.name == "AlexNetNeuralNetworkAnchor" }),
           networkAnchor.children.contains(where: { $0.name == "AlexNetConnectionLinesEntity" }) {
            print("CONNECTION LINES SUCCESSFULLY ADDED!")
        } else {
            print("CONNECTION LINES FAILED TO ADD!")
        }
        
        // 4.8) AlexNet Neural Network Layer Labelları
        let alexnetLabelsAnchor = makeAlexNetLayerLabels()
        var alexnetLabelsT = Transform()
        // Nöronlarla aynı pozisyonda
        alexnetLabelsT.translation = SIMD3<Float>(x: -2.5, y: 1.2, z: 2.1)
        alexnetLabelsAnchor.transform = alexnetLabelsT
        alexnetLabelsAnchor.isEnabled = false
        content.add(alexnetLabelsAnchor)
        
        // 4.9) AlexNet Prediction Panel
        let alexnetPredictionAnchor = Entity()
        alexnetPredictionAnchor.name = "AlexNetPredictionPanelAnchor"
        if let predictionEntity = attachments.entity(for: "alexnetPredictionPanel") {
            print("AlexNet prediction panel attachment found")
            predictionEntity.name = "AlexNetPredictionPanelEntity"
            alexnetPredictionAnchor.addChild(predictionEntity)
        } else {
            print("AlexNet prediction panel attachment NOT found")
        }
        var alexnetPredictionT = Transform()
        // Kullanıcının solunda konumlandır ve kullanıcıya dönük yap
        alexnetPredictionT.translation = SIMD3<Float>(x: -2.0, y: 1.5, z: 0.0)
        alexnetPredictionT.rotation = simd_quatf(angle: Float.pi / 2, axis: SIMD3<Float>(0, 1, 0))
        alexnetPredictionAnchor.transform = alexnetPredictionT
        alexnetPredictionAnchor.isEnabled = false
        content.add(alexnetPredictionAnchor)
        print("AlexNet prediction panel anchor added to content!")
        
        // Immediate verification
        if content.entities.contains(where: { $0.name == "AlexNetPredictionPanelAnchor" }) {
            print("AlexNet prediction panel anchor VERIFIED in content!")
        } else {
            print("AlexNet prediction panel anchor NOT FOUND after adding!")
        }
        
        // 5.5) AlexNet Feature Map Gallery Anchor'ları + Loading Anchor'ları
        // Sadece anchorları oluştur attachmentları input seçilince ekle
        for i in 0..<8 {
            let alexnetGalleryAnchor = Entity()
            alexnetGalleryAnchor.name = "AlexNetFeatureGalleryAnchor_\(i)"
            
            // Loading anchor'ını da aynı anda oluştur 
            let loadingAnchor = Entity()
            loadingAnchor.name = "AlexNetGalleryLoadingAnchor_\(i)"
                        
            var alexnetGalleryT = Transform()
            // AlexNet küplerinin tam üstünde konumlandır
            // AlexNetCubes.swift'teki pozisyonlar:
            let cubePositions: [SIMD3<Float>] = [
                // Önde 3 küp
                SIMD3<Float>(-1.2, 0, 0),    // 0: Sol
                SIMD3<Float>(0, 0, 0),       // 1: Orta
                SIMD3<Float>(1.2, 0, 0),     // 2: Sağ
                
                // Sağda 2 küp
                SIMD3<Float>(2.4, 0, 1.2),  // 3: Sağ-ön
                SIMD3<Float>(2.4, 0, 2.4),  // 4: Sağ-arka
                
                // Arkada 3 küp
                SIMD3<Float>(-1.2, 0, 3.6), // 5: Arka-sol
                SIMD3<Float>(0, 0, 3.6),    // 6: Arka-orta
                SIMD3<Float>(1.2, 0, 3.6)   // 7: Arka-sağ
            ]
            
            let cubePos = cubePositions[i]
            let galleryYOffset: Float = 0.6  // Küplerden daha yukarıda
            
            // AlexNet küp anchorının base pozisyonu
            alexnetGalleryT.translation = SIMD3<Float>(
                x: 1.2 + cubePos.x,
                y: 1.0 + galleryYOffset,
                z: -1.5 + cubePos.z
            )
            
            // Küp rotasyonlarına göre gallery rotasyonu da ayarla
            let rotations: [Float] = [
                0, 0, 0,        // Önde 3 küp - rotasyon yok
                -90, -90,       // Sağda 2 küp - -90
                180, 180, 180   // Arkada 3 küp - 180
            ]
            
            let rotationAngle = rotations[i] * Float.pi / 180.0
            alexnetGalleryT.rotation = simd_quatf(angle: rotationAngle, axis: SIMD3<Float>(0, 1, 0))
            
            alexnetGalleryAnchor.transform = alexnetGalleryT
            alexnetGalleryAnchor.isEnabled = false
            content.add(alexnetGalleryAnchor)
            
            // Loading anchor'ını da aynı pozisyonda oluştur ve ekle
            loadingAnchor.transform = alexnetGalleryT // Aynı transform
            loadingAnchor.isEnabled = false
            content.add(loadingAnchor)
        }
    }
    
    private func clearModelEntities(_ content: RealityViewContent, model: AppModel.SelectedModel?) {
        let entitiesToRemove = content.entities.filter { entity in
            switch model {
            case .lenet:
                return entity.name.contains("Lenet") || entity.name.contains("Flatten") || entity.name.contains("Dense")
            case .alexnet:
                return entity.name.contains("AlexNet")
            case .none:
                return entity.name.contains("Lenet") || entity.name.contains("AlexNet") || entity.name.contains("Flatten") || entity.name.contains("Dense")
            }
        }
        
        for entity in entitiesToRemove {
            content.remove(entity)
        }
    }
    
    private func clearLenetEntities(_ content: RealityViewContent) {
        let lenetEntities = content.entities.filter { entity in
            entity.name == "LenetCubesAnchor" ||
            entity.name == "FlattenVisualizationAnchor" || 
            entity.name == "DenseVisualizationAnchor" ||
            entity.name == "OutputVisualizationAnchor" ||  
            entity.name == "ConnectionLinesAnchor"  
        }
        for entity in lenetEntities {
            content.remove(entity)
        }
    }
    
    private func clearAlexNetEntities(_ content: RealityViewContent) {
        // Tüm AlexNet entity'lerini temizle - prediction panel dahil
        let alexnetEntities = content.entities.filter { entity in
            entity.name.hasPrefix("AlexNet")
        }
        for entity in alexnetEntities {
            content.remove(entity)
        }
    }
    
    private func recreateEntitiesForNewModel(oldModel: AppModel.SelectedModel?, newModel: AppModel.SelectedModel?) {
        let oldModelName = oldModel == .lenet ? "lenet" : (oldModel == .alexnet ? "alexnet" : "none")
        let newModelName = newModel == .lenet ? "lenet" : (newModel == .alexnet ? "alexnet" : "none")
        print("Model changed from \(oldModelName) to \(newModelName)")
    }
    
    private func resetCubeScales() {
        // Input değiştiğinde shrunkCubes setini temizle
        shrunkCubes.removeAll()
        print("Reset cube scales - cleared shrunkCubes set")
        
    }
    
    private func updateCubeScales(_ content: RealityViewContent) {
        // LeNet küpleri kontrol et
        if let lenetCubesAnchor = content.entities.first(where: { $0.name == "LenetCubesAnchor" }) {
            for i in 0..<4 {
                if let cube = lenetCubesAnchor.children.first(where: { $0.name == "LenetCube_\(i)" }) {
                    let shouldBeOpen = appModel.isCubeOpen(i)
                    let currentlyShrunken = shrunkCubes.contains(cube.name)
                    
                    // AppModel state ile visual state uyumsuzsa düzelt
                    if shouldBeOpen && !currentlyShrunken {
                        // Küp açık olmalı ama görsel olarak büyük -> küçült
                        var t = cube.transform
                        t.scale = SIMD3<Float>(repeating: 0.25)
                        cube.transform = t
                        // State değişikliğini async olarak yapak
                        DispatchQueue.main.async {
                            self.shrunkCubes.insert(cube.name)
                        }
                    } else if !shouldBeOpen && currentlyShrunken {
                        // Küp kapalı olmalı ama görsel olarak küçük -> büyüt
                        var t = cube.transform
                        t.scale = SIMD3<Float>(repeating: 1.0)
                        cube.transform = t
                        DispatchQueue.main.async {
                            self.shrunkCubes.remove(cube.name)
                        }
                    }
                }
            }
        }
        
        // AlexNet küpleri kontrol et
        if let alexnetCubesAnchor = content.entities.first(where: { $0.name == "AlexNetCubesAnchor" }) {
            for i in 0..<8 {
                if let cube = alexnetCubesAnchor.children.first(where: { $0.name == "AlexNetCube_\(i)" }) {
                    let shouldBeOpen = appModel.isAlexNetCubeOpen(i)
                    let currentlyShrunken = shrunkCubes.contains(cube.name)
                    
                    if shouldBeOpen && !currentlyShrunken {
                        var t = cube.transform
                        t.scale = SIMD3<Float>(repeating: 0.25)
                        cube.transform = t
                        DispatchQueue.main.async {
                            self.shrunkCubes.insert(cube.name)
                        }
                    } else if !shouldBeOpen && currentlyShrunken {
                        var t = cube.transform
                        t.scale = SIMD3<Float>(repeating: 1.0)
                        cube.transform = t
                        DispatchQueue.main.async {
                            self.shrunkCubes.remove(cube.name)
                        }
                    }
                }
            }
        }
    }
}

    
#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
