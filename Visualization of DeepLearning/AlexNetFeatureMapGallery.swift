//
//  AlexNetFeatureMapGallery.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 05.09.2025.
//

import SwiftUI

struct AlexNetFeatureMapGalleryView: View {
    let cubeIndex: Int
    let inputIndex: Int
    let selectedInputName: String?
    let onFeatureMapTap: (Int, Int) -> Void
    
    // Her küp için grid sayıları ve boyutları
    private var gridConfig: (count: Int, columns: Int, rows: Int) {
        let gridCounts = [64, 64, 192, 192, 384, 256, 256, 256]
        let count = gridCounts[cubeIndex]
        
        // Her küp için özel dörtgen grid boyutları
        let (cols, rows): (Int, Int)
        switch count {
        case 64:
            (cols, rows) = (8, 8)
        case 192:
            (cols, rows) = (16, 12)
        case 384:
            (cols, rows) = (24, 16)
        case 256:
            (cols, rows) = (16, 16)
        default:
            let sqrtCount = Int(ceil(sqrt(Double(count))))
            (cols, rows) = (sqrtCount, sqrtCount)
        }
        
        return (count: count, columns: cols, rows: rows)
    }
    
    // Küp isimlerini al
    private var cubeTitle: String {
        let titles = [
            "CONV1 Feature Maps (64)",
            "POOL1 Feature Maps (64)", 
            "CONV2 Feature Maps (192)",
            "POOL2 Feature Maps (192)",
            "CONV3 Feature Maps (384)",
            "CONV4 Feature Maps (256)",
            "CONV5 Feature Maps (256)",
            "POOL3 Feature Maps (256)"
        ]
        return titles[cubeIndex]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Başlık
            Text(cubeTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            // Grid - PNGleri ile LAZY LOADING
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: gridConfig.columns), spacing: 5) {
                ForEach(0..<gridConfig.count, id: \.self) { index in
                    // Tıklanabilir grid elemanları
                    Button(action: {
                        onFeatureMapTap(cubeIndex, index)
                    }) {
                        LazyImageView(
                            pngFileName: getPngFileName(for: index),
                            index: index
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: false)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
        .frame(
            width: CGFloat(gridConfig.columns * 65 + 80),
            height: CGFloat(gridConfig.rows * 65 + 160)
        )
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
    }
    
    // PNG dosya adını generate et
    private func getPngFileName(for featureMapIndex: Int) -> String {
        let inputName = getInputName()
        let layerName = getLayerName()
        return "\(inputName)_\(layerName)_\(featureMapIndex)"
    }
    
    // Input adını çıkar
    private func getInputName() -> String {
        if let selectedInput = selectedInputName {
            if selectedInput.hasPrefix("input_") {
                let suffix = selectedInput.dropFirst("input_".count)
                return suffix.description
            } else {
                return selectedInput
            }
        } else {
            return "\(inputIndex)"
        }
    }
    
    // Layer adını cube indexten çıkar
    private func getLayerName() -> String {
        let layerNames = [
            "conv1",    // 0: CONV1
            "maxp1",    // 1: POOL1  
            "conv2",    // 2: CONV2
            "maxp2",    // 3: POOL2
            "conv3",    // 4: CONV3
            "conv4",    // 5: CONV4
            "conv5",    // 6: CONV5
            "maxp3"     // 7: POOL3
        ]
        return layerNames[cubeIndex]
    }
}

// LAZY IMAGE LOADING
struct LazyImageView: View {
    let pngFileName: String
    let index: Int
    
    @State private var loadedImage: UIImage? = nil
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = loadedImage {
                // PNG yüklendiyse göster
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        // Index numarasını alt köşede göster
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(index)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                            .padding(4)
                    )
            } else if isLoading {
                // Yükleniyor placeholderı
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.7)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                // PNG bulunamadı
                RoundedRectangle(cornerRadius: 10)
                    .fill(randomColor(for: index))
                    .frame(width: 60, height: 60)
                    .overlay(
                        VStack(spacing: 2) {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(index)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
        .onAppear {
            // Görünür olduğunda PNGyi lazy load et
            loadImageAsync()
        }
    }
    
    private func loadImageAsync() {
        guard !isLoading && loadedImage == nil else { return }
        
        isLoading = true
        
        // Background threadde image yükle
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(named: pngFileName)
            
            // Main threadde UI ı güncelle
            DispatchQueue.main.async {
                self.loadedImage = image
                self.isLoading = false
            }
        }
    }
    
    private func randomColor(for index: Int) -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan,
            .indigo, .mint, .brown, .gray
        ]
        return colors[index % colors.count].opacity(0.7)
    }
    
    #Preview {
        AlexNetFeatureMapGalleryView(cubeIndex: 0, inputIndex: 0, selectedInputName: "cat") { cubeIndex, featureMapIndex in
            print("Tapped cube \(cubeIndex), feature map \(featureMapIndex)")
        }
        .preferredColorScheme(.dark)
    }
}
