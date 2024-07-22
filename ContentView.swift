import SwiftUI
import RealityKit
import RealityKitContent
import Combine

// ViewModel class to manage state and data
class ViewModel: ObservableObject {
    @Published var panelTitle: String = "Select a Panel"
    @Published var panelOptions: [String] = ["Panel 1", "Panel 2", "Panel 3"]
    @Published var selectedPanel: String? = nil
    @Published var panelDetails: [String: String] = [
        "Panel 1": "Details for Panel 1",
        "Panel 2": "Details for Panel 2",
        "Panel 3": "Details for Panel 3"
    ]
    
    func addPanel() {
        let newPanel = "Panel \(panelOptions.count + 1)"
        panelOptions.append(newPanel)
        panelDetails[newPanel] = "Details for \(newPanel)"
    }
    
    func removePanel(at offsets: IndexSet) {
        offsets.forEach { index in
            let panel = panelOptions[index]
            panelOptions.remove(at: index)
            panelDetails.removeValue(forKey: panel)
        }
    }
    
    func updatePanelDetail(panel: String, detail: String) {
        panelDetails[panel] = detail
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
    @EnvironmentObject var viewModel: ViewModel
    var panelName: String
    
    @State private var panelDetail: String = ""
    
    var body: some View {
        VStack {
            Text("Details for \(panelName)")
                .font(.title)
                .padding()
            TextField("Enter details", text: $panelDetail, onCommit: {
                viewModel.updatePanelDetail(panel: panelName, detail: panelDetail)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            Spacer()
        }
        .onAppear {
            panelDetail = viewModel.panelDetails[panelName] ?? ""
        }
    }
}

// Additional view demonstrating interaction
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
        
        let box = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let modelEntity = ModelEntity(mesh: box, materials: [material])
        let boxAnchor = AnchorEntity(world: [0, 0, -0.5])
        boxAnchor.addChild(modelEntity)
        arView.scene.addAnchor(boxAnchor)
        
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

struct SettingsView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var panelTitle: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Panel Title")) {
                TextField("Panel Title", text: $panelTitle, onCommit: {
                    viewModel.panelTitle = panelTitle
                })
            }
            Button(action: {
                panelTitle = viewModel.panelTitle
            }) {
                Text("Load Current Title")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            panelTitle = viewModel.panelTitle
        }
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
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
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
