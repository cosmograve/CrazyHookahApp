import SwiftUI

struct StatsScreen: View {
    @EnvironmentObject private var store: CrazyHookahStore
    
    let onCreateMixTap: () -> Void
    
    private let backgroundImageName = "archiveBack"
    
    private var totalMixes: Int {
        store.archivedMixes.count
    }
    
    private var tasteStats: [TasteTagStat] {
        var counter: [TasteTag: Int] = [:]
        
        for mix in store.archivedMixes {
            for flavor in mix.flavors {
                for tag in flavor.tasteTags {
                    counter[tag, default: 0] += 1
                }
            }
        }
        
        return TasteTag.allCases
            .map { tag in
                TasteTagStat(tag: tag, count: counter[tag, default: 0])
            }
            .filter { $0.count > 0 }
            .sorted { $0.count > $1.count }
    }
    
    private var totalTagCount: Int {
        tasteStats.reduce(0) { $0 + $1.count }
    }
    
    private var flavorUsage: [FlavorUsage] {
        var usage: [String: FlavorUsage] = [:]
        
        for mix in store.archivedMixes {
            for flavor in mix.flavors {
                if let existing = usage[flavor.code] {
                    usage[flavor.code] = FlavorUsage(
                        flavor: existing.flavor,
                        count: existing.count + 1
                    )
                } else {
                    usage[flavor.code] = FlavorUsage(
                        flavor: flavor,
                        count: 1
                    )
                }
            }
        }
        
        return usage.values.sorted { $0.count > $1.count }
    }
    
    private var topThreeFlavors: [FlavorUsage] {
        Array(flavorUsage.prefix(3))
    }
    
    private var topMix: HookahMix? {
        store.archivedMixes.sorted { lhs, rhs in
            let lr = lhs.rating ?? 0
            let rr = rhs.rating ?? 0
            
            if lr != rr {
                return lr > rr
            } else {
                return lhs.createdAt > rhs.createdAt
            }
        }.first
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                topBar
                
                if totalMixes == 0 {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            titleSection
                            pieChartSection
                            tasteChipsSection
                            topBlockSection
                            createMixButton
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .dynamicTypeSize(.medium)
    }
    
    private var topBar: some View {
        ZStack {
            Text("MY TOP MIXES")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
        .padding(.bottom, 12)
    }
    
    private var titleSection: some View {
        Text("YOUR TASTE\nIN NUMBERS")
            .multilineTextAlignment(.center)
            .font(.system(size: 26, weight: .heavy))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.00, green: 0.93, blue: 0.60),
                        Color(red: 0.99, green: 0.70, blue: 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color.black.opacity(0.9), radius: 14, x: 0, y: 6)
            .padding(.bottom, 8)
    }
    
    
    private var emptyTitleSection: some View {
        Text("Save your\nfirst mix\nto see your\nflavor map!")
            .multilineTextAlignment(.center)
            .font(.system(size: 36, weight: .heavy))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.00, green: 0.93, blue: 0.60),
                        Color(red: 0.99, green: 0.70, blue: 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: Color.black.opacity(0.9), radius: 14, x: 0, y: 6)
            .padding(.bottom, 8)
    }
    
    private var pieChartSection: some View {
        let wheelSize = UIScreen.main.bounds.height / 4
        
        return VStack(spacing: 10) {
            if totalTagCount == 0 {
                Text("No taste data yet")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(height: wheelSize)
            } else {
                StatsPieChart(stats: tasteStats, total: totalTagCount)
                    .frame(width: wheelSize, height: wheelSize)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tasteChipsSection: some View {
        let tags = TasteTag.allCases
        let statsByTag = Dictionary(uniqueKeysWithValues: tasteStats.map { ($0.tag, $0.count) })
        
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(tags, id: \.self) { tag in
                TasteChipView(
                    tag: tag,
                    count: statsByTag[tag] ?? 0,
                    totalCount: totalTagCount
                )
                .frame(height: 24)
            }
        }
        .padding(.top, 6)
    }
    
    private var topBlockSection: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .center, spacing: 12) {
                Text("TOP 3 Favorite Flavors")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(
                        Color(red: 1.00, green: 0.84, blue: 0.30)
                    )
                    .lineLimit(3)
                
                if topThreeFlavors.isEmpty {
                    Text("No favorite flavors yet.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    VStack(spacing: 10) {
                        ForEach(topThreeFlavors) { entry in
                            TopFlavorRow(usage: entry)
                        }
                    }
                }
            }
            .layoutPriority(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .center, spacing: 12) {
                Text("The highest rated mix")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(
                        Color(red: 1.00, green: 0.84, blue: 0.30)
                    )
                    .lineLimit(3)
                
                if let mix = topMix {
                    NavigationLink {
                        ArchiveDetailScreen(mix: mix)
                    } label: {
                        TopMixStatsCard(mix: mix)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("No mixes rated yet.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(width: 140, alignment: .leading)
        }
        .padding(.top, 8)
    }
    
    private var createMixButton: some View {
        Button {
            onCreateMixTap()
        } label: {
            Text("CREATE A MIX")
                .font(.system(size: 20, weight: .heavy))
                .kerning(1.5)
                .foregroundColor(.white)
        }
        .buttonStyle(RaisedYellowButtonStyle(isDisabled: false))
        .padding(.top, 8)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            emptyTitleSection
        
            createMixButton
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TasteTagStat: Identifiable {
    let id = UUID()
    let tag: TasteTag
    let count: Int
}

struct FlavorUsage: Identifiable {
    var id: String { flavor.code }
    let flavor: Flavor
    let count: Int
}

struct PieSliceInfo: Identifiable {
    let id: UUID
    let stat: TasteTagStat
    let startAngle: Angle
    let endAngle: Angle
}

struct StatsPieChart: View {
    let stats: [TasteTagStat]
    let total: Int
    
    private let innerRatio: CGFloat = 0.78
    
    private var slices: [PieSliceInfo] {
        var result: [PieSliceInfo] = []
        var start = Angle(degrees: -90)
        
        for stat in stats {
            let fraction = Double(stat.count) / Double(max(total, 1))
            let end = start + Angle(degrees: fraction * 360)
            let info = PieSliceInfo(
                id: stat.id,
                stat: stat,
                startAngle: start,
                endAngle: end
            )
            result.append(info)
            start = end
        }
        
        return result
    }
    
    private func color(for tag: TasteTag) -> Color {
        switch tag {
        case .fresh:   return Color(red: 0.98, green: 0.85, blue: 0.45)
        case .sour:    return Color(red: 0.99, green: 0.73, blue: 0.32)
        case .sweet:   return Color(red: 0.62, green: 0.06, blue: 0.09)
        case .floral:  return Color(red: 0.96, green: 0.35, blue: 0.22)
        case .dessert: return Color.white
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let outerRadius = size / 2
            let innerRadius = outerRadius * innerRatio
            let labelRadius = innerRadius * 0.8
            let center = CGPoint(x: geo.size.width / 2,
                                 y: geo.size.height / 2)
            
            ZStack {
                ForEach(slices) { slice in
                    DonutSliceShape(
                        startAngle: slice.startAngle,
                        endAngle: slice.endAngle,
                        innerRatio: innerRatio
                    )
                    .fill(color(for: slice.stat.tag))
                }
                
                ForEach(slices) { slice in
                    let midAngle = (slice.startAngle + slice.endAngle).radians / 2
                    let labelX = center.x + CGFloat(cos(midAngle)) * labelRadius
                    let labelY = center.y + CGFloat(sin(midAngle)) * labelRadius
                    
                    let percent = Int(
                        round(
                            Double(slice.stat.count) /
                            Double(max(total, 1)) * 100
                        )
                    )
                    
                    Text("\(percent)%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .position(x: labelX, y: labelY)
                }
            }
        }
    }
}

struct DonutSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRatio: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio
        
        let start = CGFloat(startAngle.radians)
        let end = CGFloat(endAngle.radians)
        
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        path.addLine(to: CGPoint(
            x: center.x + innerRadius * cos(end),
            y: center.y + innerRadius * sin(end)
        ))
        
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )
        
        path.closeSubpath()
        return path
    }
}

struct PieSliceShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

struct TasteChipView: View {
    let tag: TasteTag
    let count: Int
    let totalCount: Int
    
    private var percentage: Int {
        guard totalCount > 0 else { return 0 }
        return Int(round(Double(count) / Double(totalCount) * 100))
    }
    
    private var color: Color {
        switch tag {
        case .fresh:   return Color(red: 0.98, green: 0.85, blue: 0.45)
        case .sour:    return Color(red: 0.99, green: 0.73, blue: 0.32)
        case .sweet:   return Color(red: 0.62, green: 0.06, blue: 0.09)
        case .floral:  return Color(red: 0.96, green: 0.35, blue: 0.22)
        case .dessert: return Color.white
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(tag.adjective)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 21, maxHeight: 21)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.16))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
    }
}

struct TopFlavorRow: View {
    let usage: FlavorUsage
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(usage.flavor.emoji)
                    .font(.system(size: 12))
                    .lineLimit(1)
                
                Text(usage.flavor.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 29, maxHeight: 29)
            .background(
                RoundedRectangle(cornerRadius: 14.5, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.30),
                                Color.white.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14.5, style: .continuous)
                    .stroke(Color.white.opacity(0.9), lineWidth: 1.5)
            )
            .fixedSize(horizontal: true, vertical: false)
            .layoutPriority(1)
            
            Spacer(minLength: 2)
            
            Text("used \(usage.count) time\(usage.count == 1 ? "" : "s")")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.5)
        }
    }
}

struct TopMixStatsCard: View {
    let mix: HookahMix
    
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
                Color(red: 1.0, green: 0.94, blue: 0.40).opacity(0.65),
                Color(red: 1.0, green: 0.73, blue: 0.24).opacity(0.65)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var glossGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.35),
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
            
            VStack(spacing: 10) {
                Spacer(minLength: 22)
                
                Text(mix.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 10)
                
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        GradientRatingStarView(
                            isFilled: index <= rating,
                            size: 18
                        )
                    }
                }
                
                Text(mix.formattedDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.9))
                    .padding(.top, 2)
                
                Spacer(minLength: 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 140, height: 150)
    }
}

struct StatsScreen_Previews: PreviewProvider {
    static var previews: some View {
        let store = CrazyHookahStore()
        StatsScreen(onCreateMixTap: {})
            .environmentObject(store)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 382, height: 716))
    }
}
