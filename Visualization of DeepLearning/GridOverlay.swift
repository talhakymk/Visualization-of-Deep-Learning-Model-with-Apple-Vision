//
//  GridOverlay.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 1.09.2025.
//

import SwiftUI

// Tıklanabilir Grid Overlay Component
struct GridOverlay: View {
    let rows: Int
    let cols: Int
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    let onTap: (Int, Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<cols, id: \.self) { col in
                        Rectangle()
                            .fill(.clear)
                            .frame(
                                width: imageWidth / CGFloat(cols),
                                height: imageHeight / CGFloat(rows)
                            )
                            .contentShape(Rectangle()) // Tıklanabilir alan
                            .onTapGesture {
                                onTap(row, col)
                                print("Tıklanan Nöron: Row \(row), Col \(col), Index: \(row * cols + col)")
                            }
                            .overlay(
                                Rectangle()
                                    .stroke(.white.opacity(0.1), lineWidth: 0.5)
                            )
                    }
                }
            }
        }
        .frame(width: imageWidth, height: imageHeight)
    }
}
