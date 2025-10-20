import SwiftUI
import Supabase
import PhotosUI

struct ProfileEditorWidget: View {
    @Binding var profile: Profile
    @EnvironmentObject var authService: SupabaseAuthService

    @State private var avatarImage: UIImage?
    @State private var imageSelection: PhotosPickerItem?
    @State private var isLoading = false

    @State private var fullName: String = ""

    @State private var originalProfile: Profile = Profile(id: nil, email: "", fullName: "", avatarURL: nil, gender: nil, age: nil, bio: nil)
    @State private var saveButtonEnabled = false
    @State private var loadingMessage = "Saving changes..."
    @State private var loadingTimer: Timer?

    private let loadingMessages = [
        "Creating changes...",
        "Updating profile...",
        "Saving changes..."
    ]

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Form {
                Section {
                    TextField("Full name", text: .constant(fullName))
                        .textContentType(.name)
                        .disabled(true)
                        .foregroundColor(.gray)

                    TextField("Email", text: $profile.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)

                    TextField("Gender", text: Binding(
                        get: { profile.gender ?? "" },
                        set: { profile.gender = $0.isEmpty ? nil : $0 }
                    ))


                    TextField("Age", text: Binding(
                        get: { profile.age.map(String.init) ?? "" },
                        set: { profile.age = Int($0) }
                    ))
                    .keyboardType(.numberPad)

                } header: {
                    Text("Personal Information")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Section {
                    TextEditor(text: Binding(
                        get: { profile.bio ?? "" },
                        set: { profile.bio = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(minHeight: 120)
                    .padding(4)
                } header: {
                    Text("Bio")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Section {
                    PhotosPicker(selection: $imageSelection) {
                        if let avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Text("Select Avatar")
                        }
                    }
                    .onChange(of: imageSelection) { _, newValue in
                        guard let item = newValue else { return }
                        Task { await loadImage(from: item) }
                    }
                } header: {
                    Text("Avatar")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Section {
                    Button(action: saveButtonTapped) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(saveButtonEnabled ? Color.green : Color.gray)
                                .frame(height: 55)           // Increase height
                                .frame(maxWidth: 200)        // Reduce width
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)

                            if isLoading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text(loadingMessage)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            } else {
                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(!saveButtonEnabled || isLoading)
                    .frame(maxWidth: .infinity)   // Center horizontally
                }
                .listRowBackground(Color.clear)   // Make section background transparent, if needed
            }
            .navigationTitle("Edit Profile")
            .scrollContentBackground(.hidden)
            .onAppear {
                fetchUsernameAndEmail()
                originalProfile = profile
                updateSaveButtonState()
            }
            .onChange(of: profile) {
                updateSaveButtonState()
            }
        }
    }

    // Fetch username and email from environment authService session metadata
    private func fetchUsernameAndEmail() {
        guard let user = authService.user else {
            fullName = "Unknown User"
            profile.email = ""
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

        let combinedName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        fullName = combinedName.isEmpty ? (user.email ?? "User") : combinedName

        profile.email = user.email ?? profile.email
    }

    private func loadImage(from pickerItem: PhotosPickerItem) async {
        if let data = try? await pickerItem.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            avatarImage = uiImage
        }
    }

    private func updateProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await supabase.auth.session.user
            var avatarPath = profile.avatarURL

            if let data = avatarImage?.jpegData(compressionQuality: 0.8) {
                let fileName = "\(user.id).jpeg"
                try await supabase.storage
                    .from("avatars")
                    .upload(fileName, data: data, options: FileOptions(contentType: "image/jpeg"))
                avatarPath = fileName
            }

            let updates = UpdateProfileParams(
                gender: profile.gender,
                age: profile.age,
                bio: profile.bio,
                avatar_url: avatarPath
            )

            try await supabase
                .from("profiles")
                .update(updates)
                .eq("id", value: user.id)
                .execute()

            originalProfile = profile
            updateSaveButtonState()
        } catch {
            print("❌ Error updating profile:", error)
        }
    }

    private func updateSaveButtonState() {
        saveButtonEnabled = profile != originalProfile
    }

    private func saveButtonTapped() {
        isLoading = true
        startLoadingAnimation()

        Task {
            await updateProfile()
            stopLoadingAnimation()
            isLoading = false
        }
    }

    private func startLoadingAnimation() {
        var idx = 0
        loadingMessage = loadingMessages[idx]
        loadingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            DispatchQueue.main.async {
                idx = (idx + 1) % loadingMessages.count
                loadingMessage = loadingMessages[idx]
            }
        }
    }

    private func stopLoadingAnimation() {
        loadingTimer?.invalidate()
        loadingTimer = nil
    }
}
