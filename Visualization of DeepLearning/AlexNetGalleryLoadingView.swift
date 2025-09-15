//
//  AlexNetGalleryLoadingView.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 15.09.2025.
//

import SwiftUI

struct AlexNetGalleryLoadingView: View {
    let cubeIndex: Int
    
    @State private var rotationAngle: Double = 0
    
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
        VStack(spacing: 20) {
            // Başlık
            Text(cubeTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Yükleme halkası
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: rotationAngle))
                    .animation(
                        .linear(duration: 1.0).repeatForever(autoreverses: false),
                        value: rotationAngle
                    )
                
                Image(systemName: "photo.stack")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text("Loading Feature Maps...")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.15),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
        .onAppear {
            rotationAngle = 360
        }
    }
}

#Preview {
    AlexNetGalleryLoadingView(cubeIndex: 0)
        .preferredColorScheme(.dark)
}
