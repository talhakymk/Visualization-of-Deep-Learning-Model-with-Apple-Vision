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
    let onFeatureMapTap: (Int, Int) -> Void // (cubeIndex, featureMapIndex) -> Void
    
    // Her küp için grid sayıları ve boyutları
    private var gridConfig: (count: Int, columns: Int, rows: Int) {
        let gridCounts = [64, 64, 192, 192, 384, 256, 256, 256]
        let count = gridCounts[cubeIndex]
        
        // Her küp için özel dörtgen grid boyutları
        let (cols, rows): (Int, Int)
        switch count {
        case 64:
            (cols, rows) = (8, 8)      // 8x8 = 64 (kare)
        case 192:
            (cols, rows) = (16, 12)    // 16x12 = 192 (dikdörtgen)
        case 384:
            (cols, rows) = (24, 16)    // 24x16 = 384 (dikdörtgen)
        case 256:
            (cols, rows) = (16, 16)    // 16x16 = 256 (kare)
        default:
            // Fallback: kareye yakın
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
            
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: gridConfig.columns), spacing: 5) {
                ForEach(0..<gridConfig.count, id: \.self) { index in
                    // Tıklanabilir grid elemanları
                    Button(action: {
                        onFeatureMapTap(cubeIndex, index)
                    }) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(randomColor(for: index))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("\(index)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
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
            width: CGFloat(gridConfig.columns * 65 + 80), // Daha büyük panel genişliği
            height: CGFloat(gridConfig.rows * 65 + 160)   // Daha büyük panel yüksekliği
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
    
    // Rastgele renk üretici (placeholder için)
    private func randomColor(for index: Int) -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan,
            .indigo, .mint, .brown, .gray
        ]
        return colors[index % colors.count].opacity(0.7)
    }
}

#Preview {
    AlexNetFeatureMapGalleryView(cubeIndex: 0, inputIndex: 0) { cubeIndex, featureMapIndex in
        print("Tapped cube \(cubeIndex), feature map \(featureMapIndex)")
    }
    .preferredColorScheme(.dark)
}
