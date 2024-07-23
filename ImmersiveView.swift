import SwiftUI
import RealityKit
import RealityKitContent
import Combine

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
        .onChange(of: model.flowState) { _,_ in
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

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}

// ViewModel to manage flow state
class ViewModel: ObservableObject {
    @Published var flowState: FlowState = .one
    
    enum FlowState {
        case one, two, three
    }
}

// Additional Views to demonstrate state changes
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
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
            
            Button("Reset Flow State") {
                viewModel.flowState = .one
            }
            .padding()
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
