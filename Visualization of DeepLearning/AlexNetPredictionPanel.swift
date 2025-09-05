//
//  AlexNetPredictionPanel.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 05.09.2025.
//

import SwiftUI

struct AlexNetPredictionPanel: View {
    let appModel: AppModel
    
    // Input'a göre prediction data'sı
    private var predictions: [(String, Double)] {
        let inputName = appModel.selectedInputImageName ?? ""
        
        if inputName.contains("cat") {
            return [
                ("Egyptian Cat", 0.45),
                ("Kit Fox", 0.17),
                ("Chihuahua", 0.12)
            ].sorted { $0.1 > $1.1 } // Büyükten küçüğe sırala
            
        } else if inputName.contains("dog") {
            return [
                ("Beagle Dog", 0.78),
                ("Border Collie", 0.71),
                ("Golden Retriever", 0.62)
            ].sorted { $0.1 > $1.1 } // Büyükten küçüğe sırala
            
        } else if inputName.contains("ship") {
            return [
                ("Cargo Vessel", 0.83),
                ("Container Ship", 0.69),
                ("Warship", 0.55)
            ].sorted { $0.1 > $1.1 } // Büyükten küçüğe sırala
            
        } else {
            // Default (cat) predictions
            return [
                ("Egyptian Cat", 0.45),
                ("Kit Fox", 0.17),
                ("Chihuahua", 0.12)
            ].sorted { $0.1 > $1.1 }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Panel başlığı
            Text("Prediction Results")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 24)
            
            // Prediction listesi (input'a göre dinamik)
            VStack(alignment: .leading, spacing: 12) {
                // Top predictions (input'a göre değişir)
                ForEach(0..<predictions.count, id: \.self) { index in
                    PredictionRowView(
                        className: predictions[index].0,
                        probability: predictions[index].1,
                        isTop: index == 0 // İlk (en yüksek) prediction sarı renkte
                    )
                }
                
                // Spacer for dots
                Text(".\n.\n.\n.\n.\n.")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.vertical, 16)
                
                // Bottom prediction
                PredictionRowView(className: "Toilet Tissue", probability: 0.00)
            }
            
            Spacer()
        }
        .padding(30)
        .frame(width: 800, height: 800)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}

struct PredictionRowView: View {
    let className: String
    let probability: Double
    var isTop: Bool = false
    
    var body: some View {
        HStack {
            Text(className)
                .font(.system(size: 32, weight: isTop ? .bold : .semibold))
                .foregroundColor(isTop ? .yellow : .white)
            
            Spacer()
            
            Text(String(format: "%.2f", probability))
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(isTop ? .yellow : .gray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    AlexNetPredictionPanel(appModel: AppModel())
        .preferredColorScheme(.dark)
}
