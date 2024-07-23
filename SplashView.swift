import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct SplashView: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image("UrbanCompanyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("WallCraft")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                Text("by UrbanCompany")
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
            Spacer()
            
            Button(action: {
                openWindow(id: "PanelSelectionView")
            }, label: {
                Text("Experience WallCraft")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .cornerRadius(50)
                    .frame(height: 100)
                    .frame(width: 400)
            })
            .padding(.bottom, 50)
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [.black, .gray]), startPoint: .top, endPoint: .bottom))
    }
}

struct PanelSelectionView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.panelOptions, id: \.self) { panel in
                    Button(action: {
                        viewModel.selectedPanel = panel
                        openDetailView(panel)
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
    
    private func openDetailView(_ panel: String) {
        let detailView = PanelDetailView(panelName: panel)
        let hostingController = UIHostingController(rootView: detailView.environmentObject(viewModel))
        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true, completion: nil)
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

class ViewModel: ObservableObject {
    @Published var panelOptions: [String] = ["Panel 1", "Panel 2", "Panel 3"]
    @Published var selectedPanel: String? = nil
    @Published var panelDetails: [String: String] = [
        "Panel 1": "Details for Panel 1",
        "Panel 2": "Details for Panel 2",
        "Panel 3": "Details for Panel 3"
    ]
    @Published var flowState: FlowState = .one
    @Published var isSettingsPresented = false
    @Published var selectedImage: String = "panel.png"
    
    enum FlowState {
        case one, two, three
    }
    
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
    
    func nextState() {
        switch flowState {
        case .one:
            flowState = .two
        case .two:
            flowState = .three
        case .three:
            flowState = .one
        }
    }
    
    func toggleSettings() {
        isSettingsPresented.toggle()
    }
    
    func updateSelectedImage(imageName: String) {
        selectedImage = imageName
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                ImmersiveView()
                    .environment(viewModel)
                
                Picker("Flow State", selection: $viewModel.flowState) {
                    Text("One").tag(ViewModel.FlowState.one)
                    Text("Two").tag(ViewModel.FlowState.two)
                    Text("Three").tag(ViewModel.FlowState.three)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                HStack {
                    Button("Next State") {
                        viewModel.nextState()
                    }
                    .padding()
                    
                    Button("Reset State") {
                        viewModel.flowState = .one
                    }
                    .padding()
                }
                
                Button("Settings") {
                    viewModel.toggleSettings()
                }
                .padding()
            }
            .sheet(isPresented: $viewModel.isSettingsPresented) {
                SettingsView()
                    .environment(viewModel)
            }
        }
    }
}

struct SettingsView: View {
    @Environment(ViewModel.self) private var viewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Image")) {
                    Picker("Image", selection: $viewModel.selectedImage) {
                        Text("Panel").tag("panel.png")
                        Text("Wally").tag("wally.png")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button("Close Settings") {
                    viewModel.toggleSettings()
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct ImmersiveView: View {
    @Environment(ViewModel.self) private var model
    @State private var planeEntity: Entity?
    @State private var isLoaded = false
    
    var body: some View {
        @Bindable var model = model
        RealityView { content in
            if let planeEntity = planeEntity {
                content.add(planeEntity)
            }
        }
        .onAppear {
            updatePlaneEntity() // Initial setup
        }
        .onChange(of: model.flowState) { _, _ in
            updatePlaneEntity()
            print("Flow state changed, updating plane entity")
        }
    }
    
    private func updatePlaneEntity() {
        let wallAnchor = AnchorEntity(.plane(.vertical, classification: .wall, minimumBounds: SIMD2<Float>(1.0, 0.2)))
        
        let planeMesh = MeshResource.generatePlane(width: 0.70, depth: 4.775, cornerRadius: 0.0)
        
        let material: SimpleMaterial
        switch model.flowState {
        case .one:
            material = ImmersiveView.loadImageMaterial(imageUrl: "panel.png")
        case .two:
            material = ImmersiveView.loadImageMaterial(imageUrl: "wally.png")
        case .three:
            material = ImmersiveView.loadImageMaterial(imageUrl: "panel.png")
        }
        
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
        planeEntity.name = "canvas"
        wallAnchor.addChild(planeEntity)
        
        self.planeEntity = wallAnchor
        isLoaded = true
    }
    
    static func loadImageMaterial(imageUrl: String) -> SimpleMaterial {
        do {
            let texture = try TextureResource.load(named: imageUrl)
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.texture(texture)
            return material
        } catch {
            fatalError(String(describing: error))
        }
    }
}

@main
struct MyApp: App {
    @StateObject private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(viewModel)
        }
        
        WindowGroup(id: "PanelSelectionView") {
            PanelSelectionView()
                .environmentObject(viewModel)
        }
        .windowStyle(.plain)
    }
}

#Preview {
    SplashView()
        .environment(ViewModel())
}
