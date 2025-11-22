//
//
//
//import SwiftUI
//
//struct ContentView: View {
//    @EnvironmentObject var authService: SupabaseAuthService
//    @StateObject private var recommendationStore = RecommendationStore()
//    @State private var isLoading = true
//    @State private var isAuthenticated = false
//
//    var body: some View {
//        Group {
//            if isLoading {
//                // Loading spinner
//                VStack {
//                    ProgressView("Checking session...")
//                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
//                        .foregroundColor(.white)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.green.opacity(0.5).ignoresSafeArea())
//            } else {
//                if isAuthenticated {
//                    CustomTabView() // 🔄 Replaced HomeView with custom tab bar
//                } else {
//                    SignUpView()
//                }
//            }
//        }
//        .task {
//            await checkSession()
//        }
//    }
//
//    private func checkSession() async {
//        await authService.loadSession()
//        isAuthenticated = authService.session != nil
//        isLoading = false
//
//        Task {
//            for await state in authService.client.auth.authStateChanges {
//                isAuthenticated = state.session != nil
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .environmentObject(SupabaseAuthService())
//}


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: SupabaseAuthService
    @EnvironmentObject var recommendationStore: RecommendationStore  // 👈 use env, not StateObject

    @State private var isLoading = true
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView("Checking session...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green.opacity(0.5).ignoresSafeArea())
            } else {
                if isAuthenticated {
                    CustomTabView()   // HomeView inside this will see RecommendationStore
                } else {
                    SignUpView()
                }
            }
        }
        .task {
            await checkSession()
        }
    }

    private func checkSession() async {
        await authService.loadSession()
        isAuthenticated = authService.session != nil
        isLoading = false

        Task {
            for await state in authService.client.auth.authStateChanges {
                isAuthenticated = state.session != nil
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseAuthService())
        .environmentObject(RecommendationStore())   // 👈 add this for previews too
}
