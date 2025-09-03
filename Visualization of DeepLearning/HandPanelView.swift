import SwiftUI

struct HandPanelView: View {
    @Environment(AppModel.self) private var appModel
    
    // Immersive panel açma kapama API ları
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    // Immersive paneli sadece bir kez açmak için
    @State private var isImmersiveSpaceOpened = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Hand Panel")
                .font(.headline)
                .foregroundStyle(.white)

            Button("LeNet Model") {
                appModel.selectedModel = .lenet
            }
                .buttonStyle(.borderedProminent)

            Button("AlexNet Model") {
                appModel.selectedModel = .alexnet
            }
                .buttonStyle(.bordered)
        }
        .frame(width: 220, height: 150)
        .padding(8)
        .background(.blue, in: .rect(cornerRadius: 14))
        .task{
            // Uygulama açılınca immersive alanı bir kez aç
            guard !isImmersiveSpaceOpened else { return }
            isImmersiveSpaceOpened = true
            if appModel.immersiveSpaceState == .closed {
                _ = await openImmersiveSpace(id: appModel.immersiveSpaceID)
            }
        }
    }
}
