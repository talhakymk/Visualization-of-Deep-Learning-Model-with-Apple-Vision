//
//  DenseVisualizationView.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 1.09.2025.
//

import SwiftUI

struct DenseVisualizationView: View {
    let inputIndex: Int
    let layerName: String
    let imageName: String
    let gridRows: Int
    let gridCols: Int
    let layerType: String
    @Environment(AppModel.self) private var appModel
    
    init(inputIndex: Int, layerName: String, layerType: String, gridRows: Int, gridCols: Int) {
        self.inputIndex = inputIndex
        self.layerName = layerName
        self.imageName = "\(inputIndex)_\(layerType)"
        self.gridRows = gridRows
        self.gridCols = gridCols
        self.layerType = layerType
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(layerName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Text("\(gridRows)x\(gridCols) = \(gridRows * gridCols) neurons")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 16)
            
            // Direkt PNG resmi göster + tıklanabilir grid overlay
            ZStack {
                if let image = UIImage(named: imageName) {
                    let originalWidth = CGFloat(image.size.width)
                    let originalHeight = CGFloat(image.size.height)
                    let aspectRatio = originalWidth / originalHeight
                    
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 700, height: 700)
                        .overlay(
                            // Tıklanabilir grid overlay tam olarak arkadaki PNG ile aynı konumda üst üste
                            GridOverlay(
                                rows: gridRows,
                                cols: gridCols,
                                imageWidth: aspectRatio > 1 ? 700 : 700 * aspectRatio,
                                imageHeight: aspectRatio > 1 ? 700 / aspectRatio : 700
                            ) { row, col in
                                let neuronIndex = row * gridCols + col
                                let layerKey = layerType.replacingOccurrences(of: "_", with: "") 
                                appModel.selectNeuron(layer: layerKey, index: neuronIndex)
                            }
                        )
                } else {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 700, height: 700)
                        .overlay(
                            VStack {
                                Text("PNG Bulunamadı")
                                    .foregroundColor(.white.opacity(0.7))
                                Text(imageName)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        )
                }
            }
        }
        .padding(24)
        
    }
}

#Preview {
    HStack {
        DenseVisualizationView(
            inputIndex: 0,
            layerName: "DENSE LAYER 1",
            layerType: "dense_1",
            gridRows: 12,
            gridCols: 10
        )
        
        DenseVisualizationView(
            inputIndex: 0,
            layerName: "DENSE LAYER 2", 
            layerType: "dense_2",
            gridRows: 12,
            gridCols: 7
        )
    }
    .preferredColorScheme(.dark)
}
