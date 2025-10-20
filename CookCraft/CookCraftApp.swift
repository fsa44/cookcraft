import SwiftUI

@main
struct CookcraftApp: App {
    @State private var showingSplash = true
    @StateObject private var authService = SupabaseAuthService()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content
                ContentView()
                    .environmentObject(authService)
                    .opacity(showingSplash ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: showingSplash)

                // Splash overlay
                if showingSplash {
                    SplashView {
                        withAnimation {
                            showingSplash = false
                        }
                    }
                    .transition(.opacity)
                    .environmentObject(authService)
                }
            }
            // Handle OAuth / Magic Link redirects
            .onOpenURL { url in
                Task { await authService.handleRedirect(from: url) }
            }
        }
    }
}
