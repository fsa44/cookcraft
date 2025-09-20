import SwiftUI
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: – Profile View
struct ProfileView: View {
    @StateObject private var userProfileController = UserProfileController()
    @State private var showSignOutAnimation = false
    @State private var showDeleteAnimation   = false

    // Separate state for error alert
    @State private var showProfileError = false
    @State private var profileErrorMsg  = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                List {
                    // MARK: – Profile Header
                    Section {
                        HStack(spacing: 12) {
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
                                Text(userProfileController.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .redacted(reason: userProfileController.isLoading ? .placeholder : [])
                    }

                    // MARK: – Main Menu
                    Section("Main Menu") {
                        NavigationLink(destination: AccountsView()) {
                            ProfileRow(icon: "key.fill", title: "Account")
                        }
                        NavigationLink(destination: AnalyticsView()) {
                            ProfileRow(icon: "chart.pie", title: "Meal Planner")
                        }
                        NavigationLink(destination: ProductsView()) {
                            ProfileRow(icon: "archivebox.fill", title: "Products")
                        }
                        NavigationLink(destination: ScheduleView()) {
                            ProfileRow(icon: "person.2.fill", title: "Schedule")
                        }
                    }

                    // MARK: – Settings
                    Section("Settings") {
                        NavigationLink(destination: SettingsView()) {
                            ProfileRow(icon: "gearshape.fill", title: "Settings")
                        }
                        NavigationLink(destination: VersionView()) {
                            ProfileRow(icon: "gear", title: "Version")
                        }
                    }

                    // MARK: – Sign Out / Delete
                    Section {
                        Button(action: signOut) {
                            ProfileRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", tint: .blue)
                        }
                        .alert("Signing Out", isPresented: $showSignOutAnimation) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("You have successfully signed out.")
                        }

                        Button(action: deleteAccount) {
                            ProfileRow(icon: "trash", title: "Delete Account", tint: .red)
                        }
                        .alert("Deleting Account", isPresented: $showDeleteAnimation) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("Your account has been deleted.")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)

        // Observe errorMessage publisher
        .onReceive(userProfileController.$errorMessage.compactMap { $0 }) { err in
            profileErrorMsg  = err
            showProfileError = true
        }
        .alert("Profile Error", isPresented: $showProfileError) {
            Button("OK", role: .cancel) {
                // clear after dismiss
                userProfileController.errorMessage = nil
            }
        } message: {
            Text(profileErrorMsg)
        }
    }

    // MARK: – Sign Out Logic
    private func signOut() {
        showSignOutAnimation = true
        try? Auth.auth().signOut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
            else { return }
            window.rootViewController = UIHostingController(rootView: LogInView())
            window.makeKeyAndVisible()
        }
    }

    // MARK: – Delete Account Logic
    private func deleteAccount() {
        showDeleteAnimation = true
        Auth.auth().currentUser?.delete { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard
                  let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first
                else { return }
                window.rootViewController = UIHostingController(rootView: SignUpView())
                window.makeKeyAndVisible()
            }
        }
    }
}

// MARK: – Helper Row View
struct ProfileRow: View {
    let icon: String
    let title: String
    var tint: Color = .white

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(tint)
                .frame(width: 32, height: 32)
            Text(title)
                .font(.subheadline)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: – Preview
#Preview {
    ProfileView()
}
