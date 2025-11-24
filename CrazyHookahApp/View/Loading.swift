import SwiftUI

struct Loading: View {
    private let backgroundImageName = "loadingBack"
    var onFinish: () -> Void = {}
    
    @State private var progress: CGFloat = 0.0
    
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
                
                loadingBar
                    .padding(.bottom, 60)
            }
            .padding(.vertical, 48)
        }
        .onAppear { animate() }
    }
    
    private var loadingBar: some View {
        VStack(spacing: 14) {
            Text("loading…")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.28, blue: 0.15),
                                    Color(red: 0.78, green: 0.05, blue: 0.05)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * progress))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .frame(height: 23)
            .padding(.horizontal, 42)
        }
    }
    
    private func animate() {
        withAnimation(.easeInOut(duration: 3)) {
            progress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            onFinish()
        }
    }
}

#Preview {
    Loading(onFinish: {})
        .preferredColorScheme(.dark)
}
