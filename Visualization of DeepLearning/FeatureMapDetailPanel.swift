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
    let onClose: () -> Void
    
    // Panel bilgileri
    private var panelTitle: String {
        let cubeNames = [
            "CONV1", "POOL1", "CONV2", "POOL2", 
            "CONV3", "CONV4", "CONV5", "POOL3"
        ]
        return "\(cubeNames[cubeIndex]) - Feature Map \(featureMapIndex)"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Başlık çubuğu
            HStack {
                Text(panelTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Kapatma butonu
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                        .background(Color.red.opacity(0.3))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // İçerik alanı (şimdilik placeholder)
            VStack(spacing: 20) {
                // Feature map preview alanı (gelecekte PNG gelecek)
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Feature Map Preview")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("PNG will be loaded here")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                
                // Bilgi alanı
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(title: "Cube Index:", value: "\(cubeIndex)")
                    InfoRow(title: "Feature Map:", value: "\(featureMapIndex)")
                    InfoRow(title: "Input Index:", value: "\(inputIndex)")
                    InfoRow(title: "Layer Type:", value: getLayerType())
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(width: 500, height: 600)
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
        inputIndex: 0
    ) {
        print("Panel closed")
    }
    .preferredColorScheme(.dark)
}
