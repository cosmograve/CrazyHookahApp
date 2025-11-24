import SwiftUI

@main
struct CrazyHookahAppApp: App {
    @StateObject private var store = CrazyHookahStore()
    var body: some Scene {
        WindowGroup {
            CrazyHookahRootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
