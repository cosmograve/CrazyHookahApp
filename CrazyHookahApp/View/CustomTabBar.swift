import SwiftUI

struct TopRoundedRectangle: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    
    private let activeRed = Color(red: 1.0, green: 0.22, blue: 0.24)
    private let inactiveGray = Color.white.opacity(0.4)
    private let barHeight: CGFloat = 94
    
    var body: some View {
        ZStack(alignment: .top) {
            TopRoundedRectangle(radius: 26)
                .fill(Color.black)
            HStack {
                tabButton(
                    iconName: "archive_icon",
                    title: "Archive",
                    tab: .archive
                )
                
                Spacer()
                
                wheelButton
                
                Spacer()
                
                tabButton(
                    iconName: "stats_icon",
                    title: "Statistics",
                    tab: .stats
                )
            }
            .padding(.horizontal, 40)
            .padding(.top, 18)
        }
        .frame(height: barHeight)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
    
    private func tabButton(
        iconName: String,
        title: String,
        tab: TabItem
    ) -> some View {
        let isSelected = (selectedTab == tab)
        
        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(isSelected ? activeRed : inactiveGray)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? activeRed : inactiveGray)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var wheelButton: some View {
        let isSelected = (selectedTab == .wheel)
        
        return Button {
            selectedTab = .wheel
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 57, height: 57)
                    .shadow(
                        color: Color.black.opacity(0.6),
                        radius: 6,
                        x: 0,
                        y: 2
                    )
                
                
                Image("wheel_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(isSelected ? activeRed : inactiveGray)
            }
        }
        .buttonStyle(.plain)
        .offset(y: -10)
    }
}
