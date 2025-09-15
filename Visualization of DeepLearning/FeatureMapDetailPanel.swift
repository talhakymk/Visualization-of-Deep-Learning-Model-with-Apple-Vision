//
//  FeatureMapDetailPanel.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 05.09.2025.
//

import SwiftUI

struct FeatureMapDetailPanel: View {
    let cubeIndex: Int
    let featureMapIndex: Int
    let inputIndex: Int
    let selectedInputName: String?
    let onClose: () -> Void
    
    // Hover efekti için bool
    @State private var isCloseButtonHovered = false
    @State private var isDragHandleHovered = false
    
    // Panel bilgileri
    private var panelTitle: String {
        let cubeNames = [
            "CONV1", "POOL1", "CONV2", "POOL2", 
            "CONV3", "CONV4", "CONV5", "POOL3"
        ]
        return "\(cubeNames[cubeIndex]) - Feature Map \(featureMapIndex)"
    }
    
    // PNG dosya adını generate et
    private var pngFileName: String {
        // Input adını belirle
        let inputName = getInputName()
        
        // Layer adını belirle
        let layerName = getLayerName()
        
        // Dosya adı: input_layer_index
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
            let inputNames = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
            return inputNames[min(inputIndex, inputNames.count - 1)]
        }
    }
    
    // Layer adını cube index'ten çıkar
    private func getLayerName() -> String {
        let layerNames = [
            "conv1",
            "maxp1",
            "conv2",
            "maxp2",
            "conv3",
            "conv4",
            "conv5",
            "maxp3"
        ]
        return layerNames[cubeIndex]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(panelTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Kapatma butonu
                ZStack {
                    Circle()
                        .fill(isCloseButtonHovered ? Color.red.opacity(0.9) : Color.red.opacity(0.6))
                        .frame(width: 50, height: 50) // Tıklanabilir alanı
                        .scaleEffect(isCloseButtonHovered ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isCloseButtonHovered)
                    
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .onHover { hovering in
                    isCloseButtonHovered = hovering
                }
                .onTapGesture {
                    print("Close button tapped: \(cubeIndex)-\(featureMapIndex)")
                    onClose()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // İçerik alanı
            VStack(spacing: 20) {
                // Feature map preview alanı
                Group {
                    if let image = UIImage(named: pngFileName) {
                        // PNG bulundu
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    } else {
                        // PNG bulunamadı
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(0.3),
                                        Color.orange.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 300, height: 300)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo.badge.exclamationmark")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Text("PNG Not Found")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(pngFileName)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                            )
                    }
                }
                
                // Bilgi alanı
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(title: "Input:", value: getInputName())
                    InfoRow(title: "Layer:", value: getLayerName().uppercased())
                    InfoRow(title: "Feature Map:", value: "\(featureMapIndex)")
                    InfoRow(title: "Layer Type:", value: getLayerType())
                    InfoRow(title: "PNG File:", value: pngFileName)
                }
                .padding(.horizontal, 20)
            }
            
            // Alttaki drag handle kısmı
            VStack(spacing: 4) {
                Text("Drag to move")
                    .font(.caption2)
                    .foregroundColor(isDragHandleHovered ? .white.opacity(0.8) : .white.opacity(0.4))
                    .animation(.easeInOut(duration: 0.2), value: isDragHandleHovered)
                
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isDragHandleHovered ? Color.white.opacity(0.8) : Color.white.opacity(0.4))
                        .frame(width: isDragHandleHovered ? 50 : 40, height: isDragHandleHovered ? 8 : 6)
                        .animation(.easeInOut(duration: 0.2), value: isDragHandleHovered)
                    Spacer()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDragHandleHovered ? Color.white.opacity(0.1) : Color.clear)
                    .animation(.easeInOut(duration: 0.2), value: isDragHandleHovered)
            )
            .onHover { hovering in
                isDragHandleHovered = hovering
            }
            .accessibilityIdentifier("DragHandle_\(cubeIndex)_\(featureMapIndex)")
            
            Spacer()
        }
        .frame(width: 500, height: 630)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.25),
                    Color(red: 0.05, green: 0.05, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
    }
    
    // Layer tipini belirle
    private func getLayerType() -> String {
        let layerTypes = [
            "Convolution", "Max Pooling", "Convolution", "Max Pooling",
            "Convolution", "Convolution", "Convolution", "Max Pooling"
        ]
        return layerTypes[cubeIndex]
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.cyan)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    FeatureMapDetailPanel(
        cubeIndex: 0,
        featureMapIndex: 5,
        inputIndex: 0,
        selectedInputName: "cat"
    ) {
        print("Panel closed")
    }
    .preferredColorScheme(.dark)
}
