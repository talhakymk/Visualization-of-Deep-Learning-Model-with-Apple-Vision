/*import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hello, Talha!")

            ToggleImmersiveSpaceButton()
        }
        .padding()
        .onAppear {
            // Uygulama açılır açılmaz panel penceresini göster
            openWindow(id: "HandPanel")
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}*/
