import SwiftUI

enum TabItem {
    case archive
    case wheel
    case stats
}

struct CrazyHookahRootView: View {
    @StateObject private var store = CrazyHookahStore()
    @State private var selectedTab: TabItem = .wheel
    
    private let tabBarHeight: CGFloat = 94
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                selectedContent
                    .environmentObject(store)
                    .padding(.bottom, tabBarHeight)
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .archive:
            ArchiveScreen()
                .background(
                    Image("archiveBack")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
        case .wheel:
            WheelScreen()
        case .stats:
            StatsScreen() {
                selectedTab = .wheel
            }
            .background(
                Image("archiveBack")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    CrazyHookahRootView()
}
