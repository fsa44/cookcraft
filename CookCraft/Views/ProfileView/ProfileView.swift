import SwiftUI
import Supabase

struct ProfileView: View {
    @EnvironmentObject var authService: SupabaseAuthService

    @State private var profile = Profile(
        id: nil,
        email: "",
        fullName: "",
        avatarURL: nil,
        gender: "",
        age: nil,
        bio: ""
    )
    @State private var showEditor = false
    @State private var isLoading = false
    @State private var userInitials: String = "US"

    // MARK: - Alerts
    @State private var showSignOutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showSignOutSuccess = false
    @State private var showDeleteSuccess = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // Background GRADIENT NOW MATCHES HOMEVIEW
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#58B361"),
                        Color(hex: "#264D2A")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    // MARK: - Top Section
                    HStack(alignment: .center) {
                        // Left: Email
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Profile")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            Text(profile.email.isEmpty ? "example@email.com" : profile.email)
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        Spacer()
                        // Right: Avatar + Name + Gender
                        Button(action: { showEditor.toggle() }) {
                            VStack(alignment: .trailing, spacing: 6) {
                                // Avatar / Initials
                                Text(userInitials)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 77, height: 77)
                                    .background(Color.white.opacity(0.25))
                                    .clipShape(Circle())

                                // Full Name
                                Text(profile.fullName.isEmpty ? "User" : profile.fullName)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .frame(maxWidth: 150, alignment: .trailing)
                                    .padding(.trailing, 5)

                                // Gender
                                Text((profile.gender ?? "").isEmpty ? "Gender" : (profile.gender ?? ""))
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: 150, alignment: .trailing)
                                    .padding(.trailing, 5)
                            }
                            .padding(.top, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.top, -20)
                    
                    Divider()
                        .background(Color.white.opacity(0.5))

                    // MARK: - Edit Profile Button
                    Button(action: { showEditor.toggle() }) {
                        HStack {
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                        .shadow(radius: 6)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    // MARK: - Navigate to Dietary Preferences
                    NavigationLink(destination: DietaryPreferencesWidget()) {
                        HStack {
                            Text("Dietary Preferences")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "leaf")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                        .shadow(radius: 6)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    // MARK: - Navigate to Analytics Widget
                    NavigationLink(destination: AnalyticsWidget()) {
                        HStack {
                            Text("Analytics")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chart.bar.xaxis") // You can use another SF Symbol if preferred
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                        .shadow(radius: 6)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    // MARK: - Navigate to BMI Results Widget

                    Spacer()

                    // MARK: - BIO Section
                    Divider()
                        .background(Color.white.opacity(0.5))
                        .padding(.bottom, 10)
                        .padding(.top, -35)
                    // MARK: - BIO Section
                    Divider()
                        .background(Color.white.opacity(0.5))
                        .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Me")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        if let bio = profile.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
//                                .fixedSize(horizontal: false, vertical: true) // ← ensures wrapping
                                .lineLimit(nil)
                        } else {
                            Text("No bio added yet.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)

                    // MARK: - Sign Out / Delete Account Section
                    Divider()
                        .background(Color.white.opacity(0.5))
                        .padding(.vertical, 8)

                    VStack(spacing: 16) {
                        // Sign Out Button
                        Button(action: { showSignOutConfirm = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.blue)
                                Text("Sign Out")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                        }

                        // Delete Account Button
                        Button(role: .destructive, action: { showDeleteConfirm = true }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Delete Account")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.25))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)   // adjust this value if you want the buttons higher/lower

                    .padding(.bottom, 105) // Change here to adjust how close of far the about and sign/delete button move up overally on the screen
                } // VStack
            } // ZStack
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditor) {
                ProfileEditorWidget(profile: $profile)
            }
            .task {
                await loadProfile()
                fetchUserName()
            }
            // MARK: - Alerts
            .alert("Confirm Sign Out", isPresented: $showSignOutConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await handleSignOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }

            .alert("Confirm Delete Account", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await handleDeleteAccount()
                    }
                }
            } message: {
                Text("This action cannot be undone. Your account and data will be permanently deleted.")
            }

            .alert("Signed Out", isPresented: $showSignOutSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You have successfully signed out.")
            }

            .alert("Account Deleted", isPresented: $showDeleteSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your account has been permanently deleted.")
            }

            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Load Profile from Database
    private func loadProfile() async {
        do {
            let user = try await supabase.auth.session.user
            let data: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: user.id)
                .single()
                .execute()
                .value

            profile = data
        } catch {
            print("❌ Failed to load profile:", error)
        }
    }

    // MARK: - Fetch User Name + Initials
    private func fetchUserName() {
        guard let user = authService.user else {
            self.profile.fullName = "Guest"
            self.profile.email = "guest@example.com"
            self.userInitials = "GG"
            return
        }

        var first = ""
        var last = ""

        if let meta = user.userMetadata["first_name"], case let .string(value) = meta {
            first = value
        }
        if let meta = user.userMetadata["last_name"], case let .string(value) = meta {
            last = value
        }

        let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        let emailFallback = user.email ?? "User"

        self.profile.fullName = fullName.isEmpty ? emailFallback : fullName
        self.profile.email = user.email ?? ""

        if !first.isEmpty || !last.isEmpty {
            let firstInitial = first.first.map { String($0).uppercased() } ?? ""
            let lastInitial = last.first.map { String($0).uppercased() } ?? ""
            self.userInitials = "\(firstInitial)\(lastInitial)"
        } else if let email = user.email {
            let parts = email.components(separatedBy: "@").first ?? ""
            let chars = parts.prefix(2).uppercased()
            self.userInitials = chars
        } else {
            self.userInitials = "US"
        }
    }

    // MARK: - Sign Out Logic
    private func handleSignOut() async {
        do {
            try await authService.logOut()
            showSignOutSuccess = true
            print("✅ User signed out successfully.")
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    // MARK: - Delete Account Logic
    private func handleDeleteAccount() async {
        do {
            guard let user = authService.user else { return }

            // Delete profile data
            try await authService.client
                .from("profiles")
                .delete()
                .eq("id", value: user.id)
                .execute()

            // Delete Supabase auth user
            try await authService.client.auth.admin.deleteUser(id: user.id)

            // Log out locally
            try await authService.logOut()
            showDeleteSuccess = true
            print("🗑️ Account deleted successfully.")
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(SupabaseAuthService())
}
