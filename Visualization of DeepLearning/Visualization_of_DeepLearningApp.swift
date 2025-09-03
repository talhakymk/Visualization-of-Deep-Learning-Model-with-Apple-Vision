import SwiftUI

@main
struct Visualization_of_DeepLearningApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        // Panel için ayrı 2D pencere (küçük boyut ve sol-önde konum)
        WindowGroup(id: "HandPanel") {
            HandPanelView()
                .environment(appModel)
                .padding(12)
        }
        .defaultSize(width: 220, height: 150)     // points
        .windowStyle(.plain)

        // Immersive alan (Show Immersive Space ile açılır)
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear { appModel.immersiveSpaceState = .open }
                .onDisappear { appModel.immersiveSpaceState = .closed }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
