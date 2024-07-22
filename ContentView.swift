import SwiftUI
import RealityKit
import RealityKitContent
import Combine

// ViewModel class to manage state and data
class ViewModel: ObservableObject {
    @Published var panelTitle: String = "Select a Panel"
    @Published var panelOptions: [String] = ["Panel 1", "Panel 2", "Panel 3"]
    @Published var selectedPanel: String? = nil
    
    func addPanel() {
        let newPanel = "Panel \(panelOptions.count + 1)"
        panelOptions.append(newPanel)
    }
    
    func removePanel(at offsets: IndexSet) {
        panelOptions.remove(atOffsets: offsets)
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.panelTitle)
                .font(.largeTitle)
                .padding()
            PanelSelectionView()
            HStack {
                Button(action: {
                    viewModel.addPanel()
                }) {
                    Text("Add Panel")
                }
                .padding()
                Button(action: {
                    viewModel.panelOptions.removeAll()
                }) {
                    Text("Clear All Panels")
                }
                .padding()
            }
        }
    }
}

struct PanelSelectionView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.panelOptions, id: \.self) { panel in
                Button(action: {
                    viewModel.selectedPanel = panel
                }) {
                    Text(panel)
                }
            }
            .onDelete(perform: viewModel.removePanel)
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Panels")
        .onAppear {
            print("PanelSelectionView appeared")
        }
    }
}

struct PanelDetailView: View {
    var panelName: String
    
    var body: some View {
        VStack {
            Text("Details for \(panelName)")
                .font(.title)
                .padding()
            Spacer()
        }
    }
}

struct InteractionView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            if let selectedPanel = viewModel.selectedPanel {
                PanelDetailView(panelName: selectedPanel)
            } else {
                Text("No Panel Selected")
                    .font(.headline)
            }
            Spacer()
            Button(action: {
                viewModel.selectedPanel = nil
            }) {
                Text("Clear Selection")
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}

struct RealityKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let anchor = try! Experience.loadBox()
        arView.scene.anchors.append(anchor)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ARContentView: View {
    var body: some View {
        RealityKitView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct MainView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Panels")
                }
            ARContentView()
                .tabItem {
                    Image(systemName: "arkit")
                    Text("AR View")
                }
            InteractionView()
                .tabItem {
                    Image(systemName: "hand.tap")
                    Text("Interact")
                }
        }
    }
}

@main
struct MyApp: App {
    @StateObject private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
        }
    }
}
