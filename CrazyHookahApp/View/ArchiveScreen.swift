import SwiftUI

struct ArchiveScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: CrazyHookahStore
    
    private let backgroundImageName = "archiveBack"
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]
    
    @State private var mixPendingDeletion: HookahMix?
    @State private var isDeleteAlertPresented: Bool = false
    
    var body: some View {
        ZStack {
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 24) {
                        ForEach(store.archivedMixes) { mix in
                            NavigationLink {
                                ArchiveDetailScreen(mix: mix)
                            } label: {
                                ArchiveMixCardView(
                                    mix: mix,
                                    onDeleteTap: {
                                        mixPendingDeletion = mix
                                        isDeleteAlertPresented = true
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .dynamicTypeSize(.medium)
        .alert("Delete this mix?", isPresented: $isDeleteAlertPresented, presenting: mixPendingDeletion) { mix in
            Button("Delete", role: .destructive) {
                store.deleteMixFromArchive(mix)
            }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("This action cannot be undone.")
        }
    }
    
    private var topBar: some View {
        ZStack {
            HStack {
                Button {
                    store.startNewSession()
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.30),
                                    Color.white.opacity(0.10)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Text("ARCHIVE")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.top, 28)
        .padding(.bottom, 12)
    }
}

struct ArchiveMixCardView: View {
    let mix: HookahMix
    let onDeleteTap: () -> Void
    
    private var rating: Int {
        max(0, min(5, mix.rating ?? 0))
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 1.0, green: 0.92, blue: 0.40),
                Color(red: 0.99, green: 0.68, blue: 0.26)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var fillGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.18, green: 0.17, blue: 0.13),
                Color(red: 0.11, green: 0.10, blue: 0.08)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var glossGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.30),
                Color.clear
            ]),
            startPoint: .topTrailing,
            endPoint: .center
        )
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(borderGradient, lineWidth: 3)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(fillGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(glossGradient)
                        .mask(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                        )
                )
            
            HStack {
                Button {
                    onDeleteTap()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.55))
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if (mix.rating ?? 0) <= 3 {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.38, blue: 0.24),
                                        Color(red: 0.90, green: 0.12, blue: 0.10)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("!")
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(.white)
                    }
                    .frame(width: 26, height: 26)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
            
            VStack(spacing: 14) {
                Spacer(minLength: 34)
                
                Text(mix.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { index in
                        GradientRatingStarView(
                            isFilled: index <= rating,
                            size: 22
                        )
                    }
                }
                
                Text(mix.formattedDate)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(.top, 4)
                
                Spacer(minLength: 22)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 190)
    }
}

struct ArchiveDetailScreen: View {
    let mix: HookahMix
    
    private let backgroundImageName = "archiveBack"
    @Environment(\.dismiss) private var dismiss
    
    private var rating: Int {
        max(0, min(5, mix.rating ?? 0))
    }
    
    var body: some View {
        ZStack {
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                    .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    ArchiveDetailCard(mix: mix, rating: rating)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
            }
        }
        .dynamicTypeSize(.medium)
        .navigationBarBackButtonHidden(true)
    }
    
    private var topBar: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.30),
                                    Color.white.opacity(0.10)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Text("ARCHIVE")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.top, 28)
        .padding(.bottom, 12)
    }
}

struct ArchiveDetailCard: View {
    let mix: HookahMix
    let rating: Int
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.94, blue: 0.40),
                            Color(red: 1.0, green: 0.73, blue: 0.24)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.5),
                        radius: 16, x: 0, y: 8)
            
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(mix.formattedDate)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black.opacity(0.75))
                        .padding(.top, 16)
                    
                    Text(mix.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.25),
                                radius: 3, x: 0, y: 1)
                }
                .padding(.horizontal, 24)
                
                FlavorChipsGrid(flavors: mix.flavors)
                    .padding(.horizontal, 24)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(red: 0.90, green: 0.20, blue: 0.20), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                        )
                    
                    Text(mix.profile.tagline.uppercased())
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .frame(height: 80)
                .padding(.horizontal, 24)
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { index in
                        GradientRatingStarView(
                            isFilled: index <= rating,
                            size: 28
                        )
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 26)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.45
        
        var path = Path()
        let points = 5
        let angleStep = .pi * 2 / Double(points * 2)
        
        for i in 0..<(points * 2) {
            let angle = Double(i) * angleStep - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct GradientRatingStarView: View {
    let isFilled: Bool
    let size: CGFloat
    
    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.84, blue: 0.20),
                Color(red: 0.98, green: 0.55, blue: 0.12)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var emptyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.40),
                Color.white.opacity(0.18)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        let style: AnyShapeStyle = isFilled
            ? AnyShapeStyle(fillGradient)
            : AnyShapeStyle(emptyGradient)
        
        StarShape()
            .fill(style)
            .frame(width: size, height: size)
            .overlay(
                StarShape()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(
                color: Color.black.opacity(0.35),
                radius: 2,
                x: 0,
                y: 1
            )
    }
}

struct FlavorChipsGrid: View {
    let flavors: [Flavor]
    
    private var rows: [[Flavor]] {
        var result: [[Flavor]] = []
        var index = 0
        
        while index < flavors.count {
            let end = min(index + 2, flavors.count)
            result.append(Array(flavors[index..<end]))
            index += 2
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 12) {
                    ForEach(row) { flavor in
                        chip(for: flavor)
                    }
                    
                    if row.count == 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }
    
    private func chip(for flavor: Flavor) -> some View {
        Text(flavor.name.uppercased())
            .font(.system(size: 13, weight: .heavy))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.black.opacity(0.7))
            )
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

private struct ArchiveScreenPreviewHost: View {
    @StateObject private var store: CrazyHookahStore
    
    @MainActor
    init() {
        _store = StateObject(wrappedValue: CrazyHookahStore())
    }
    
    var body: some View {
        NavigationStack {
            ArchiveScreen()
                .environmentObject(store)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ArchiveScreenPreviewHost()
}
