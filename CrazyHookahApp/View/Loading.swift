import SwiftUI

struct Loading: View {
    private let backgroundImageName = "loadingBack"
    
    var body: some View {
        ZStack {
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(.logoImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 48)
                
                Spacer()
                
                loadingBarStatic
                    .padding(.bottom, 60)
            }
            .padding(.vertical, 48)
        }
    }
    
    private var loadingBarStatic: some View {
        VStack(spacing: 14) {
            Text("loading…")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.18))
                .frame(height: 23)
                .padding(.horizontal, 42)
        }
    }
}

#Preview {
    Loading()
}
