import SwiftUI

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
                    .cornerRadius(50)
                    .frame(height: 100)
                    .frame(width: 400)
            })
            .padding(.bottom, 50)
        }
        .padding()
        .background(Color.clear)
    }
}

#Preview {
    SplashView()
        .environment(ViewModel())
}
