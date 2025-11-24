import SwiftUI


struct CrazyHookahRootView: View {
    @EnvironmentObject private var store: CrazyHookahStore
    
    var body: some View {
        NavigationStack {
            Group {
                switch store.screenState {
                case .start:
                    Loading()
                case .wheel, .result, .rating, .archive:
                    WheelScreen()
                }
            }
            .navigationDestination(isPresented: $store.isArchiveActive) {
                ArchiveScreen()
                    .navigationBarBackButtonHidden()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
