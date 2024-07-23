import SwiftUI
import RealityKit
import RealityKitContent

struct PanelSelectionView: View {
    
    @Environment(ViewModel.self) private var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
  
    let imageUrls = [
        "https://picsum.photos/200/300",
        "https://picsum.photos/200/301",
        "https://picsum.photos/200/302",
        "https://picsum.photos/200/303",
        "https://picsum.photos/200/304",
        "https://picsum.photos/200/305",
        "https://picsum.photos/200/306",
        "https://picsum.photos/200/307",
        "https://picsum.photos/200/308",
        "https://picsum.photos/200/309",
        "https://picsum.photos/200/310"
    ]
    
    @State private var currentCenterIndex = 0
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        @Bindable var model = model
        VStack(alignment: .center) {
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
            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: -30) {
                        ForEach(circularArray(from: imageUrls), id: \.self) { url in
                            GeometryReader { geometry in
                                AsyncImage(url: URL(string: url)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 400) // Adjusted height to make images look like panels
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .shadow(radius: 10)
                                        .padding(.vertical, 10)
                                        .opacity(opacity(for: geometry.frame(in: .global).midX, viewWidth: proxy.size.width))
                                        .scaleEffect(scale(for: geometry.frame(in: .global).midX, viewWidth: proxy.size.width))
                                        .zIndex(Double(geometry.frame(in: .global).midX))
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 200, height: 400) // Adjusted placeholder height
                                        .background(Color.gray.opacity(0.3))
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .shadow(radius: 5)
                                        .padding(.vertical, 10)
                                }
                                .onTapGesture {
                                    withAnimation {
                                        scrollToCenter(url: url, in: proxy)
                                    }
                                }
                            }
                            .frame(width: 200, height: 500)
                        }
                    }
                    .padding(.leading, (proxy.size.width - 200) / 2)
                    .padding(.trailing, (proxy.size.width - 200) / 2)
                    .offset(x: scrollOffset)
                }
            }
        }
        .padding(50)
        .background(Color.clear)
    }
    
    private func opacity(for xPosition: CGFloat, viewWidth: CGFloat) -> Double {
        let midScreen = viewWidth / 2
        let diffFromCenter = abs(midScreen - xPosition)
        let maxOpacityDistance: CGFloat = 200 // Adjust this value as needed
        let minOpacity: Double = 0.2 // Opacity for images not in center
        let maxOpacity: Double = 1.0 // Opacity for image in center
        let opacity = max(minOpacity, maxOpacity - (diffFromCenter / maxOpacityDistance))
        return opacity
    }
    
    private func scale(for xPosition: CGFloat, viewWidth: CGFloat) -> CGFloat {
        let midScreen = viewWidth / 2
        let diffFromCenter = abs(midScreen - xPosition)
        let scale = max(0.7, 1 - diffFromCenter / midScreen)
        return scale
    }
    
    private func scrollToCenter(url: String, in proxy: GeometryProxy) {
        guard let index = imageUrls.firstIndex(of: url) else { return }
        let newOffset = CGFloat(index) * 230 // Adjusted based on the width of each image including the spacing
        scrollOffset = -newOffset + (proxy.size.width - 200) / 2
    }
    
    private func circularArray(from array: [String]) -> [String] {
        var extendedArray = array
        if !array.isEmpty {
            extendedArray.append(contentsOf: array)
            extendedArray.append(contentsOf: array)
        }
        return extendedArray
    }
}

#Preview(windowStyle: .automatic) {
    PanelSelectionView()
        .environment(ViewModel())
}
