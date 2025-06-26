import SwiftUI

struct ProfileView: View {
    @StateObject private var userProfileController = UserProfileController()
    @State private var showSignOutAnimation = false
    @State private var showDeleteAnimation = false
    @State private var notifications: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                List {
                    // Profile Section
                    Section {
                        HStack {
                            Text(userProfileController.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 55, height: 55)
                                .background(Color(.systemGray))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(userProfileController.fullName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)

                                Text(userProfileController.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .redacted(reason: userProfileController.isLoading ? .placeholder : [])
                    }

                    // Main Menu Section
                    Section("Main Menu") {
                        NavigationLink(destination: AccountsView()) {
                            ProfileComponents(
                                imageName: "key.fill",
                                title: "Account",
                                tintColor: Color(.systemGray),
                                scrollOffset: 0)
                        }

                        NavigationLink(destination: AnalyticsView()) {
                            ProfileComponents(
                                imageName: "chart.pie",
                                title: "Meal Planner",
                                tintColor: Color(.systemGray),
                                scrollOffset: 0)
                        }

                        NavigationLink(destination: ProductsView()) {
                            ProfileComponents(
                                imageName: "archivebox.fill",
                                title: "Products",
                                tintColor: Color(.systemGray),
                                scrollOffset: 0)
                        }

                        NavigationLink(destination: ScheduleView()) {
                            ProfileComponents(
                                imageName: "person.2.fill",
                                title: "Schedule",
                                tintColor: Color(.systemGray),
                                scrollOffset: 0)
                        }
                    }

                    // Settings Section
                    Section("Settings") {
                        NavigationLink(destination: SettingsView()) {
                            ProfileComponents(
                                imageName: "gearshape.fill",
                                title: "Settings",
                                tintColor: Color(.systemGray),
                                scrollOffset: 0)
                        }

                        NavigationLink(destination: VersionView()) {
                            ProfileComponents(
                                imageName: "gear",
                                title: "Version",
                                tintColor: Color(.systemGray),
                                scrollOffset: 0)
                        }
                    }

                    // Sign Out and Delete Account Section
                    Section {
                        Button(action: signOut) {
                            ProfileComponents(
                                imageName: "rectangle.portrait.and.arrow.right",
                                title: "Sign Out",
                                tintColor: Color(.systemBlue),
                                scrollOffset: 0)
                        }
                        .alert("Signing Out", isPresented: $showSignOutAnimation) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("You have successfully signed out.")
                        }

                        Button(action: deleteAccount) {
                            ProfileComponents(
                                imageName: "trash",
                                title: "Delete Account",
                                tintColor: Color(.red),
                                scrollOffset: 0)
                        }
                        .alert("Deleting Account", isPresented: $showDeleteAnimation) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Your account has been deleted.")
                        }
                    }
                }
                .scrollContentBackground(.hidden) // Make List background transparent
            }
        }
    }

    // Placeholder Sign Out Logic
    func signOut() {
        showSignOutAnimation = true
        print("User signed out")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: LogInView())
                window.makeKeyAndVisible()
            }
        }
    }

    // Placeholder Delete Logic
    func deleteAccount() {
        showDeleteAnimation = true
        print("User account deleted")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = UIHostingController(rootView: SignUpView())
                window.makeKeyAndVisible()
            }
        }
    }
}



#Preview {
    ProfileView()
}


struct ProfileComponents: View {
    let imageName: String
    let title: String
    let tintColor: Color
    let scrollOffset: CGFloat

    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(tintColor)
                .frame(width: 32, height: 32)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
