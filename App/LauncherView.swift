import SwiftUI
import FirebaseAuth

struct LauncherView: View {
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Image("Blu_Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .ignoresSafeArea()
                .onAppear {
                    // Show logo for 1.5 seconds, then go to GetStarted screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                    }
                }
            } else {
                GetStartedView()
            }
        }
    }
}
