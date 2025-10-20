import SwiftUI
import Supabase

// MARK: - Main Sign Up View
struct SignUpView: View {
    // MARK: - Supabase Auth Service (injected)
    @EnvironmentObject private var authService: SupabaseAuthService

    // MARK: - User Input Fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    // MARK: - UI State Flags
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false

    // MARK: - Password Visibility Toggles
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    // MARK: - Loading Messages
    @State private var loadingMessages = [
        "Encrypting your ingredients...",
        "Whipping up your profile...",
        "Cooking up credentials...",
        "Preheating the database...",
        "Stirring the cloud soup...",
        "Chopping data onions...",
        
        // New curated additions:
        "Grating some firewalls...",
        "Simmering your settings...",
        "Marinating your metadata...",
        "Toasting your tokens...",
        "Dusting off the cookies...",
        "Baking some byte-sized treats...",
        "Slicing up session layers...",
        "Mixing logic into the batter...",
        "Seasoning your experience...",
        "Garnishing the UI...",
        "Letting the servers rest...",
        "Rolling out fresh updates...",
        "Plating your dashboard...",
        "Whisking through the backend...",
        "Sautéing your preferences...",
        "Measuring twice, compiling once..."
    ]


    @State private var currentFullMessage: String = ""
    @State private var typedMessage: String = ""
    @State private var loadingMessageTimer: Timer?
    @State private var typingTimer: Timer?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "1B3528"), Color(hex: "4F9B75")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Branding
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign Up")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Cookcraft.")
                            .font(.custom("Avenir", size: 67))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)

                    // Form
                    Section(
                        header: Text("Enter Details")
                            .font(.custom("Avenir", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                    ) {
                        inputField("First Name", text: $firstName)
                        inputField("Last Name", text: $lastName)
                        inputField("Email", text: $email, isEmail: true)
                        secureInputField("Password", text: $password, isVisible: $showPassword)
                        secureInputField("Confirm Password", text: $confirmPassword, isVisible: $showConfirmPassword)
                    }

                    // Button or Spinner with Typing Text
                    if isLoading {
                        VStack(spacing: 8) {
                            ProgressView()
                                .padding(.bottom, 4)

                            Text(typedMessage)
                                .font(.footnote.monospaced())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                                .id(currentFullMessage)
                                .animation(.easeInOut(duration: 0.3), value: typedMessage)
                        }
                    } else {
                        Button(action: signUpWithSupabase) {
                            Text("Sign Up")
                                .frame(width: 260, height: 58)
                                .background(isFormValid ? Color(hex: "2D8E6D") : Color.gray.opacity(0.55))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 10)
                    }

                    // Log In Nav
                    NavigationLink(destination: LogInView()) {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.white)
                    }

                    // Navigation on successful sign up
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                            .transition(.move(edge: .trailing))
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Sign Up"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }

    // MARK: - Validation
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword
    }

    // MARK: - Sign Up with Supabase
    private func signUpWithSupabase() {
        do {
            try validateForm()
            isLoading = true
            startLoadingMessages() // Start text animations

            Task {
                do {
                    try await authService.signUp(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password,
                        firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                        lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                    await MainActor.run {
                        isLoading = false
                        stopLoadingMessages()
                        if authService.session != nil {
                            navigateToHome = true
                        } else {
                            alertMessage = "Check your email to confirm your account, then sign in."
                            showAlert = true
                        }
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        stopLoadingMessages()
                        alertMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                        showAlert = true
                    }
                }
            }
        } catch {
            alertMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            showAlert = true
        }
    }

    // MARK: - Form Validation Logic
    private func validateForm() throws {
        let nameRegex = "^[A-Za-z]+([\\s-][A-Za-z]+)*$"
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let passwordRegex = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"#

        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        let fullName = "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))"

        guard namePredicate.evaluate(with: fullName) else {
            throw SignUpError.invalidName
        }
        guard emailPredicate.evaluate(with: email) else {
            throw SignUpError.invalidEmail
        }
        guard passwordPredicate.evaluate(with: password) else {
            throw SignUpError.invalidPassword
        }
        guard password == confirmPassword else {
            throw SignUpError.passwordsDoNotMatch
        }
    }

    // MARK: - Reusable Inputs
    private func inputField(_ title: String, text: Binding<String>, isEmail: Bool = false) -> some View {
        TextField(title, text: text)
            .padding(.horizontal, 10)
            .frame(height: 55)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            .autocapitalization(isEmail ? .none : .words)
            .keyboardType(isEmail ? .emailAddress : .default)
            .disableAutocorrection(true)
    }

    private func secureInputField(_ title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            Group {
                if isVisible.wrappedValue {
                    TextField(title, text: text)
                        .textContentType(.newPassword)
                } else {
                    SecureField(title, text: text)
                        .textContentType(.newPassword)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(.horizontal, 10)
            .frame(height: 55)

            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
    }

    // MARK: - Loading Animation
    private func startLoadingMessages() {
        showNewLoadingMessage()
        loadingMessageTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            showNewLoadingMessage()
        }
    }

    private func showNewLoadingMessage() {
        stopTypingAnimation()
        let newMessage = loadingMessages.randomElement() ?? ""
        currentFullMessage = newMessage
        typedMessage = ""
        startTypingAnimation(for: newMessage)
    }

    private func startTypingAnimation(for message: String) {
        var charIndex = 0
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if charIndex < message.count {
                let index = message.index(message.startIndex, offsetBy: charIndex)
                typedMessage += String(message[index])
                charIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }

    private func stopTypingAnimation() {
        typingTimer?.invalidate()
        typingTimer = nil
    }

    private func stopLoadingMessages() {
        loadingMessageTimer?.invalidate()
        typingTimer?.invalidate()
        loadingMessageTimer = nil
        typingTimer = nil
    }
}

// MARK: - Validation Errors
enum SignUpError: Error, LocalizedError {
    case invalidName
    case invalidEmail
    case invalidPassword
    case passwordsDoNotMatch

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Please enter a valid first and last name."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidPassword:
            return "Password must be at least 8 characters, include a number and a special character."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        }
    }
}

// MARK: - Hex Color Utility
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview
#Preview {
    SignUpView()
        .environmentObject(SupabaseAuthService())
}
