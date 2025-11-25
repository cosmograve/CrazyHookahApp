import SwiftUI

struct WheelScreen: View {
    @EnvironmentObject private var store: CrazyHookahStore
    
    private let wheelImageName = "wheel"
    private let pointerImageName = "wheel_pointer"
    private let backgroundImageName = "loadingBack"
    
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.6
    
    @State private var isSaveSheetPresented: Bool = false
    @State private var isRatingOverlayPresented: Bool = false
    
    private var canSpinMore: Bool {
        !store.isSpinning && store.currentSpinCount < store.maxSpins
    }
    
    private var hasAnyFlavor: Bool {
        !store.currentSelectedFlavors.isEmpty
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    topSection
                        .frame(height: geo.size.height * 0.75)
                    
                    bottomSection
                        .frame(height: geo.size.height * 0.25)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    if isSaveSheetPresented {
                        SaveCancelSheetView(
                            onSave: {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    isSaveSheetPresented = false
                                    
                                    if let mix = store.currentMix {
                                        store.currentRating = mix.rating ?? 0
                                        store.currentNote = mix.profile.tagline
                                    } else {
                                        store.currentRating = 0
                                        store.currentNote = ""
                                    }
                                    
                                    isRatingOverlayPresented = true
                                }
                            },
                            onCancel: {
                                withAnimation(.easeOut(duration: 0.25)) {
                                    isSaveSheetPresented = false
                                }
                                store.cancelCurrentMixAndReturnToWheel()
                            }
                        )
                        .frame(height: geo.size.height * 0.4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                if isRatingOverlayPresented, let mix = store.currentMix {
                    RatingOverlayView(
                        mix: mix,
                        rating: $store.currentRating,
                        onSave: {
                            store.saveCurrentMixToArchive()
                            withAnimation(.easeOut(duration: 0.25)) {
                                isRatingOverlayPresented = false
                            }
                            store.openArchive()
                            store.isArchiveActive = true
                        },
                        onCancel: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                isRatingOverlayPresented = false
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .dynamicTypeSize(.medium)
        .onAppear {
            glowScale = 1.0
            glowOpacity = 0.6
        }
        .onChange(of: store.isSpinning) { spinning in
            startGlowAnimation(spinning: spinning)
        }
    }
    
    private var topSection: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 24)
            
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(
                        width: UIScreen.main.bounds.width / 1.25,
                        height: UIScreen.main.bounds.width / 1.25
                    )
                    .blur(radius: 35)
                    .scaleEffect(glowScale)
                    .opacity(glowOpacity)
                
                Image(wheelImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width / 1.2)
                    .rotationEffect(.degrees(store.currentWheelRotation))
                
                Image(pointerImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .offset(y: -160)
            }
            
            VStack(spacing: 8) {
                Text("Mix Composition")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                
                if let mix = store.currentMix {
                    Text(mix.title.uppercased())
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.white)
                }
                
                MixSlotsView(
                    flavors: store.currentSelectedFlavors,
                    maxSlots: store.maxSpins
                )
                .padding(.horizontal, 32)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private var bottomSection: some View {
        ZStack {
            Color.clear
            
            VStack(spacing: 16) {
                if let mix = store.currentMix {
                    MixProfileSummaryView(mix: mix)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.25)) {
                                isSaveSheetPresented = true
                            }
                        }
                    
                } else if hasAnyFlavor {
                    Button {
                        guard canSpinMore else { return }
                        store.spinWheel()
                    } label: {
                        Text("KEEP SPINNING")
                            .font(.system(size: 20, weight: .heavy))
                            .kerning(1.5)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(
                        RaisedYellowButtonStyle(
                            isDisabled: !canSpinMore
                        )
                    )
                    .disabled(!canSpinMore)
                    
                    Button {
                        guard !store.isSpinning else { return }
                        store.userRequestedMixGeneration()
                    } label: {
                        Text("CREATE A MIX")
                            .font(.system(size: 20, weight: .heavy))
                            .kerning(1.5)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(
                        RaisedYellowButtonStyle(
                            isDisabled: store.isSpinning || store.currentSelectedFlavors.isEmpty
                        )
                    )
                    .disabled(store.isSpinning || store.currentSelectedFlavors.isEmpty)
                    
                } else {
                    Button {
                        guard canSpinMore else { return }
                        store.spinWheel()
                    } label: {
                        Text(store.isSpinning ? "SPINNING..." : "SPIN")
                            .font(.system(size: 35, weight: .heavy))
                            .kerning(2)
                            .foregroundColor(.white)
                            .shadow(color: Color.blue.opacity(0.8),
                                    radius: 0, x: 0, y: 2)
                    }
                    .buttonStyle(
                        RaisedRedButtonStyle(
                            isDisabled: !canSpinMore
                        )
                    )
                    .disabled(!canSpinMore)
                    
                    if !store.isSpinning && !store.archivedMixes.isEmpty  {
                        Button {
                            store.openArchive()
                            store.isArchiveActive = true
                        } label: {
                            Text("ARCHIVE")
                                .font(.system(size: 20, weight: .heavy))
                                .kerning(1.5)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(
                            RaisedYellowButtonStyle(isDisabled: false)
                        )
                    }
                }
            }
        }
    }
    
    private func startGlowAnimation(spinning: Bool) {
        if spinning {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowScale = 1.04
                glowOpacity = 0.8
            }
        } else {
            withAnimation(.easeOut(duration: 0.3)) {
                glowScale = 1.0
                glowOpacity = 0.6
            }
        }
    }
}

struct MixSlotsView: View {
    let flavors: [Flavor]
    let maxSlots: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    MixSlotCell(title: title(for: index))
                }
            }
            HStack(spacing: 12) {
                ForEach(3..<maxSlots, id: \.self) { index in
                    MixSlotCell(title: title(for: index))
                }
            }
        }
    }
    
    private func title(for index: Int) -> String? {
        guard index < flavors.count else { return nil }
        return flavors[index].name
    }
}

struct MixSlotCell: View {
    let title: String?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .frame(height: 38)
            
            if let title {
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 8)
            }
        }
    }
}

struct RaisedRedButtonStyle: ButtonStyle {
    let isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && !isDisabled
        
        if isDisabled {
            return AnyView(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.90, green: 0.25, blue: 0.22),
                                Color(red: 0.78, green: 0.08, blue: 0.08)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 64)
                    .overlay(
                        configuration.label
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .opacity(0.7)
                    .padding(.horizontal, 32)
            )
        }
        
        return AnyView(
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.70, green: 0.10, blue: 0.10))
                    .frame(height: 64)
                    .offset(y: 6)
                
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.98, green: 0.30, blue: 0.22),
                                Color(red: 0.90, green: 0.10, blue: 0.10)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 64)
                    .overlay(
                        configuration.label
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .offset(y: isPressed ? 6 : 0)
            }
            .padding(.horizontal, 32)
            .animation(.easeOut(duration: 0.12), value: isPressed)
        )
    }
}

struct RaisedYellowButtonStyle: ButtonStyle {
    let isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed && !isDisabled
        
        let topColorLeft  = Color(red: 1.00, green: 0.93, blue: 0.35)
        let topColorRight = Color(red: 0.99, green: 0.67, blue: 0.20)
        let bottomColor   = Color(red: 0.88, green: 0.52, blue: 0.15)
        
        if isDisabled {
            return AnyView(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [topColorLeft, topColorRight]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 56)
                    .overlay(
                        configuration.label
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .opacity(0.7)
                    .padding(.horizontal, 32)
            )
        }
        
        return AnyView(
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(bottomColor)
                    .frame(height: 56)
                    .offset(y: 5)
                
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [topColorLeft, topColorRight]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 56)
                    .overlay(
                        configuration.label
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .offset(y: isPressed ? 5 : 0)
            }
            .padding(.horizontal, 32)
            .animation(.easeOut(duration: 0.12), value: isPressed)
        )
    }
}

struct MixProfileSummaryView: View {
    let mix: HookahMix
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Your Hookah Will Be:")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(red: 0.90, green: 0.20, blue: 0.20), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                    )
                
                Text(mix.profile.description.uppercased())
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
            }
            .frame(height: 56)
        }
        .padding(.horizontal, 32)
    }
}

struct SaveCancelSheetView: View {
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.6),
                            Color.black
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.6), radius: 16, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 20) {
                Spacer()
                
                Button(action: onSave) {
                    Text("SAVE")
                        .font(.system(size: 20, weight: .heavy))
                        .kerning(1.5)
                        .foregroundColor(.white)
                }
                .buttonStyle(RaisedYellowButtonStyle(isDisabled: false))
                
                Button(action: onCancel) {
                    Text("CANCEL")
                        .font(.system(size: 20, weight: .heavy))
                        .kerning(1.5)
                        .foregroundColor(.white)
                }
                .buttonStyle(RaisedYellowButtonStyle(isDisabled: false))
                
                Spacer()
            }
        }
    }
}

struct RatingOverlayView: View {
    let mix: HookahMix
    @Binding var rating: Int
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                Text("DO YOU LIKE THE MIX?")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        Button {
                            rating = index
                        } label: {
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .foregroundColor(
                                    index <= rating
                                    ? Color.yellow
                                    : Color.white.opacity(0.4)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Your Hookah:")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(red: 0.90, green: 0.20, blue: 0.20), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white)
                            )
                        
                        Text(mix.profile.tagline.uppercased())
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 16)
                    }
                    .frame(height: 60)
                }
                
                Button(action: {
                    onSave()
                }) {
                    Text("SAVE TO ARCHIVE")
                        .font(.system(size: 20, weight: .heavy))
                        .kerning(1.5)
                        .foregroundColor(.white)
                }
                .buttonStyle(RaisedRedButtonStyle(isDisabled: rating == 0))
                .disabled(rating == 0)
            }
            .padding(.horizontal, 32)
        }
    }
}



#Preview {
    WheelScreen()
        .environmentObject(CrazyHookahStore())
}
