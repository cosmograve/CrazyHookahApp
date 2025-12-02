import SwiftUI

@main
struct CrazyHookahAppApp: App {
    var body: some Scene {
        WindowGroup {
            CrazyHookahRootView()
                .preferredColorScheme(.dark)
        }
    }
}
