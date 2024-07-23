import SwiftUI
import RealityKit
import Combine

class ViewModel: ObservableObject {
    @Published var panelTitle: String = "Select a Panel"
    @Published var panelOptions: [String] = ["Panel 1", "Panel 2", "Panel 3"]
    @Published var selectedPanel: String? = nil
    @Published var panelDetails: [String: String] = [
        "Panel 1": "Details for Panel 1",
        "Panel 2": "Details for Panel 2",
        "Panel 3": "Details for Panel 3"
    ]
    @Published var searchText: String = ""
    @Published var doodlePoints: [CGPoint] = []
    @Published var panelDescription: String = "Default Description"
    
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
    
    func filteredPanels() -> [String] {
        if searchText.isEmpty {
            return panelOptions
        } else {
            return panelOptions.filter { $0.contains(searchText) }
        }
    }
    
    func addDoodlePoint(_ point: CGPoint) {
        doodlePoints.append(point)
    }
    
    func clearDoodle() {
        doodlePoints.removeAll()
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
        VStack {
            TextField("Search Panels", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            List {
                ForEach(viewModel.filteredPanels(), id: \.self) { panel in
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
    @State private var panelDescription: String = ""
    
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
            Section(header: Text("Panel Description")) {
                TextField("Panel Description", text: $panelDescription, onCommit: {
                    viewModel.panelDescription = panelDescription
                })
            }
            Button(action: {
                panelDescription = viewModel.panelDescription
            }) {
                Text("Load Current Description")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            panelTitle = viewModel.panelTitle
            panelDescription = viewModel.panelDescription
        }
    }
}

struct DoodleView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            Path { path in
                for (i, point) in viewModel.doodlePoints.enumerated() {
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(Color.black, lineWidth: 2)
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged { value in
            viewModel.addDoodlePoint(value.location)
        })
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.clearDoodle()
                    }) {
                        Text("Clear Doodle")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
        )
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
            DoodleView()
                .tabItem {
                    Image(systemName: "pencil.and.outline")
                    Text("Doodle")
                }
        }
    }
}

@main
struct DoodleApp: App {
    @StateObject private var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
        }.windowStyle(.plain)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(viewModel)
        }
        
        WindowGroup(id:"PanelView"){
            PanelView()
                .environmentObject(viewModel)
        }.windowStyle(.plain)
        
        WindowGroup(id:"PanelSelectionView"){
            PanelSelectionView()
                .environmentObject(viewModel)
        }.windowStyle(.plain)
    }
}
