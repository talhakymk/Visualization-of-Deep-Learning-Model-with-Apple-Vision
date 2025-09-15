//
//  OutputVisualizationView.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 02.09.2025.
//

import SwiftUI

import SwiftUI

struct OutputVisualizationView: View {
    let appModel: AppModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Output Layer\n\t10x1")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            // Lnetteki output sonucu için dikey panel
            VStack(spacing: 30) {
                ForEach(0..<10, id: \.self) { digit in
                    ZStack {
                        // Her sayı için arkaplan
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 65)
                        
                        // seçili inputu siyahla işaretleyeilm
                        if digit == appModel.currentInputIndex {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black)
                                .frame(width: 70, height: 55)
                        }
                        
                        // Digit text
                        Text("\(digit)")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(digit == appModel.currentInputIndex ? .white : .primary)
                    }
                }
            }
            .frame(width: 90, height: 900)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}
