//import SwiftUI
//
//@main
//struct CookcraftApp: App {
//    @State private var showingSplash = true
//    @StateObject private var authService = SupabaseAuthService()
//    @StateObject private var recommendationStore = RecommendationStore()
//
//    var body: some Scene {
//        WindowGroup {
//            ZStack {
//                // Main content
//                ContentView()
//                    .environmentObject(authService)
//                    .opacity(showingSplash ? 0 : 1)
//                    .animation(.easeInOut(duration: 0.5), value: showingSplash)
//
//                // Splash overlay
//                if showingSplash {
//                    SplashView {
//                        withAnimation {
//                            showingSplash = false
//                        }
//                    }
//                    .transition(.opacity)
//                    .environmentObject(authService)
//                    .environmentObject(recommendationStore)
//                }
//            }
//            // Handle OAuth / Magic Link redirects
//            .onOpenURL { url in
//                Task { await authService.handleRedirect(from: url) }
//            }
//        }
//    }
//}


import SwiftUI

@main
struct CookcraftApp: App {
    @State private var showingSplash = true
    @StateObject private var authService = SupabaseAuthService()
    @StateObject private var recommendationStore = RecommendationStore()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content
                ContentView()
                    .environmentObject(authService)
                    .environmentObject(recommendationStore)     // 👈 ADD THIS
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
                    .environmentObject(recommendationStore)     // 👈 this is already correct
                }
            }
            .onOpenURL { url in
                Task { await authService.handleRedirect(from: url) }
            }
        }
    }
}
