

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
       PanelSelectionView()
    }
}

#Preview {
    ContentView()
        .environment(ViewModel())
}
