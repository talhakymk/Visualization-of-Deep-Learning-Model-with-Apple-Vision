//
//  LenetFilters.swift
//  Visualization of DeepLearning
//
//  Created by Melike SEYİTOĞLU on 27.08.2025.
//

import SwiftUI

struct LenetSmallFiltersPanel: View {
    private let imageNames: [String] = (0..<6).map { "lenet_filter_2x2_\($0)" }
    
    private let descriptions: [String] = [
        "FILTER-1 \n0.1436145 \n0.41274172 \n0.37006384 \n-0.3338682",
        "FILTER-2 \n0.36392194 \n0.5671656 \n0.33062437 \n0.2797875",
        "FILTER-3 \n-0.35958698 \n0.31445003 \n0.3566598 \n0.4647417",
        "FILTER-4 \n0.2831421 \n0.40183255 \n-0.17446826 \n-0.1130608",
        "FILTER-5 \n0.42979705 \n0.23169805 \n-0.11316572 \n0.47212687",
        "FILTER-6 \n-0.17651269 \n-0.06156456 \n0.24071108 \n0.58496"
    ]
    
    @State private var selectedIndex: Int? = nil
    
    var onTap: (Int) -> Void = { _ in }
    
    var body: some View {
        ZStack {
            // Mavi arka plan (panelin tamamı)
            Color.blue.opacity(0.85)
                .clipShape(.rect(cornerRadius: 16))

            VStack(spacing: 10) {
                // ÜST: 2 satır x 3 sütun grid (butonlar üst bölgede dursun)
                VStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { col in
                                let idx = row * 3 + col
                                Button {
                                    selectedIndex = idx
                                    onTap(idx)
                                } label: {
                                    Image(imageNames[idx])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 70)
                                        .clipped()
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 8))
                            }
                        }
                    }
                }

                // ORTA: Boşluk (metin için alt bölgeyi açmak amacıyla)
                Spacer(minLength: 8)

                // ALT: Tıklanınca görünen metin alanı
                if let idx = selectedIndex {
                    Text(descriptions[safe: idx] ?? "\(idx)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                }
            }
            .padding(12)
        }
        // Panel boyutu: butonlar + alttaki metin için yeterli yükseklik
        .frame(width: 420, height: 320)
    }
}

struct LenetLargeFiltersPanel: View {
    private let imageNames: [String] = (0..<16).map { "lenet_filter_5x5_\($0)" }

    var body: some View {
        VStack(spacing: 8) {
            // 4 satır 4 sutun
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { col in
                        let idx = row * 4 + col
                        Image(imageNames[idx])
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                            .clipped()
                            .contentShape(Rectangle())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 500, height: 500) // panel boyutu
        .background(.blue.opacity(0.85), in: .rect(cornerRadius: 16))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
