import SwiftUI
import RealityKit
import RealityKitContent


struct MainPanelView: View {
    
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        ZStack {
            //seçilen modele göre içerik
            panelContent
        }
        // Model değişince orta seçimi sıfırla
         .onChange(of: appModel.selectedModel) { _, _ in
             appModel.selectedInputImageName = nil
         }
    }

    
    @ViewBuilder
    private var panelContent: some View {
        switch appModel.selectedModel {
        case .lenet:
            // Başlık yukarıda metin tam ortada görsel grid aşağıda
            ZStack {
                // Üst başlık
                VStack(spacing: 0) {
                    Text("MNIST DATASET ON LENET MODEL")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 100)
                    Spacer()
                }
                
                // Orta alan
                Group{
                    if let name = appModel.selectedInputImageName {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 6)
                            .accessibilityLabel(Text(name))
                    } else {
                        Text("Select Input...")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Alt kısım
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    let inputNames = (0..<10).map { "input_\($0)" }
                    
                    VStack(spacing: 10) {
                        // 1. satır
                        HStack(spacing: 0) {
                            ForEach(0..<5) { idx in
                                Button {
                                    appModel.selectedInputImageName = inputNames[idx]
                                } label: {
                                    Image(inputNames[idx])
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                                        .clipped()
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                            }
                        }
                        .clipShape(.rect(cornerRadius: 8))
                        
                        // 2. satır
                        HStack(spacing: 0) {
                            ForEach(5..<10) { idx in
                                Button {
                                    appModel.selectedInputImageName = inputNames[idx]
                                } label: {
                                    Image(inputNames[idx])
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75)
                                        .clipped()
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                            }
                        }
                        .clipShape(.rect(cornerRadius: 8))
                    }
                    .padding(.bottom, 250)
                }
            }
            
        case .alexnet:
            // Başlık yukarıda metin ortada altta 3 görsel buton (cat, dog, ship)
            ZStack {
                // Üst başlık
                VStack(spacing: 0) {
                    Text("IMAGENET DATASET ON ALEXNET MODEL")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 50)
                    Spacer()
                }
                
                // Orta alan
                Group{
                    if let name = appModel.selectedInputImageName {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .shadow(radius: 6)
                            .accessibilityLabel(Text(name))
                    } else {
                        Text("Select Input...")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // 3 görsel buton
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 10) {
                        ForEach(["cat", "dog", "ship"], id: \.self) { name in
                            Button {
                                appModel.selectedInputImageName = name
                            } label: {
                                Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                                    .clipped()
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 8))
                        }
                    }
                    .padding(.bottom, 350)
                }
            }
         
        case .none:
            // Henüz seçim yoksa yönlendirici metin
            Text("Model seçmek için HandPanel’den bir butona basın")
                .font(.title3)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
    }
}

