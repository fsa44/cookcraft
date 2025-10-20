


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: SupabaseAuthService
    @State private var isLoading = true
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isLoading {
                // Loading spinner
                VStack {
                    ProgressView("Checking session...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green.opacity(0.5).ignoresSafeArea())
            } else {
                if isAuthenticated {
                    CustomTabView() // 🔄 Replaced HomeView with custom tab bar
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
}
