
import SwiftUI

@main
struct DoodleApp: App {
    @State private var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }.windowStyle(.plain)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(viewModel)
        }
        
        WindowGroup(id:"PanelView"){
            PanelView()
                .environment(viewModel)
        }.windowStyle(.plain)
        
        
        WindowGroup(id:"PanelSelectionView"){
            PanelSelectionView()
                .environment(viewModel)
        }.windowStyle(.plain)
    }
}
