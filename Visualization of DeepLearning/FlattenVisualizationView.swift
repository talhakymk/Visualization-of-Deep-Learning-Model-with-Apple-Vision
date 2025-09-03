//
//  FlattenVisualizationView.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 1.09.2025.
//

import SwiftUI

struct FlattenVisualizationView: View {
    let inputIndex: Int
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack(spacing: 4) {
            Text("FLATTEN LAYER")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Text("16x16 = 256 neurons")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 16)
            
            // Direkt PNG resmi göster + tıklanabilir grid overlay
            ZStack {
                if let image = UIImage(named: "\(inputIndex)_flatten") {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 700, height: 700)
                } else {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 700, height: 700)
                        .overlay(
                            Text("PNG Bulunamadı")
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                
                // 16x16 tıklanabilir grid overlay
                GridOverlay(
                    rows: 16,
                    cols: 16,
                    imageWidth: 700,
                    imageHeight: 700
                ) { row, col in
                    let neuronIndex = row * 16 + col
                    appModel.selectNeuron(layer: "flatten", index: neuronIndex)
                }
            }
        }
        .padding(24)
    }
}

#Preview {
    FlattenVisualizationView(inputIndex: 0)
        .preferredColorScheme(.dark)
}
