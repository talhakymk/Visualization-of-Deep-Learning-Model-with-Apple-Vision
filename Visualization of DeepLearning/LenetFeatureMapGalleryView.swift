//
//  LenetFeatureMapGalleryView.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 28.08.2025.
//

import SwiftUI

/// Seçilen küpe göre gelen görselleri grid olarak gösterir.
/// - images: gösterilecek görsel adları (Assets.xcassets içinde)
/// - columns/rows: grid düzeni
struct LenetFeatureMapGalleryView: View {
    let images: [String]
    let columns: Int
    let rows: Int

    var body: some View {
        VStack(spacing: 8) {
            // Grid
            let cellCount = min(images.count, columns * rows)
            let rowChunks = stride(from: 0, to: cellCount, by: columns).map { start in
                Array(images[start..<min(start + columns, cellCount)])
            }

            VStack(spacing: 8) {
                ForEach(0..<rowChunks.count, id: \.self) { r in
                    HStack(spacing: 8) {
                        ForEach(rowChunks[r], id: \.self) { name in
                            ZStack {
                                // Fallback için placeholder
                                Rectangle()
                                    .fill(.gray.opacity(0.3))
                                    .frame(height: 64)
                                
                                // Gerçek resim - Bundle'dan manuel yükleme
                                if let uiImage = UIImage(named: name) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 64)
                                        .clipped()
                                } else {
                                    // Eğer bulamazsa error göster
                                    VStack {
                                        Image(systemName: "exclamationmark.triangle")
                                            .foregroundColor(.red)
                                        Text("\(name)")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    }
                                    .frame(height: 64)
                                }
                            }
                            .onAppear {
                                print("Trying to load image: \(name)")
                                if UIImage(named: name) == nil {
                                    print(" Failed to load image: \(name)")
                                } else {
                                    print(" Successfully loaded image: \(name)")
                                }
                            }
                            .contentShape(Rectangle())
                            .frame(maxWidth: .infinity)
                            .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 520) // toplam genişlik
    }
}
