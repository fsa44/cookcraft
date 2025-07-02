//
//  SignUpView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//  Updated by ChatGPT on 02/07/2025.
//

import SwiftUI
import FirebaseAuth

// MARK: - Main Sign Up View
struct SignUpView: View {

    // MARK: - User Input Fields (Form Data)
    // These @State properties hold user-entered values
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    // MARK: - UI State Flags
    // These control loading, alerts, and navigation state
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false

    // MARK: - Password Visibility Toggles
    // Used to toggle visibility for password text fields
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "1B3528"), Color(hex: "4F9B75")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {

                    // MARK: - Branding Text
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

                    // MARK: - Form Inputs
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

                    // MARK: - Sign Up Button / Loading Spinner
                    if isLoading {
                        ProgressView().padding()
                    } else {
                        Button(action: signUp) {
                            Text("Sign Up")
                                .frame(width: 260, height: 58)
                                .background(Color(hex: "2D8E6D"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }

                    // MARK: - Navigation to Log In
                    NavigationLink(destination: LogInView()) {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.white)
                    }

                    // MARK: - Navigation to Home (on success)
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Sign Up Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }

    // MARK: - Sign Up Function
    /// Handles form validation, calls Firebase, sets display name, and navigates on success
    private func signUp() {
        do {
            // 1. Validate form input before hitting Firebase
            try validateForm()
            isLoading = true

            // 2. Create new user with Firebase
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error as NSError? {
                        // 3. Handle Firebase error and show user-friendly alert
                        alertMessage = firebaseErrorMessage(from: error)
                        showAlert = true
                        return
                    }

                    // 4. Set display name for the user (optional)
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.displayName = "\(firstName) \(lastName)"
                        changeRequest.commitChanges { _ in }
                    }

                    // 5. Navigate to Home on success
                    navigateToHome = true
                }
            }
        } catch {
            // Handle form validation errors
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    // MARK: - Form Validation Logic
    /// Validates name, email, password format, and password match
    private func validateForm() throws {
        let nameRegex = "^[A-Za-z]+(?:[\\s-][A-Za-z]+)*$"
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let passwordRegex = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"#

        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        // Validate full name
        guard namePredicate.evaluate(with: "\(firstName) \(lastName)") else {
            throw SignUpError.invalidName
        }

        // Validate email format
        guard emailPredicate.evaluate(with: email) else {
            throw SignUpError.invalidEmail
        }

        // Validate password strength
        guard passwordPredicate.evaluate(with: password) else {
            throw SignUpError.invalidPassword
        }

        // Check if passwords match
        guard password == confirmPassword else {
            throw SignUpError.passwordsDoNotMatch
        }
    }

    // MARK: - Firebase Error Mapping
    /// Maps FirebaseAuth error codes to user-friendly messages
    private func firebaseErrorMessage(from error: NSError) -> String {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return error.localizedDescription
        }

        switch code {
        case .invalidEmail:
            return "The email address is badly formatted."
        case .emailAlreadyInUse:
            return "This email is already in use. Please log in or use another email."
        case .weakPassword:
            return "The password is too weak. It must be at least 8 characters, with letters, numbers, and special characters."
        case .networkError:
            return "Network error. Please check your internet connection."
        default:
            return error.localizedDescription
        }
    }

    // MARK: - Reusable Input TextField
    /// Text input used for first name, last name, and email
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

    // MARK: - Secure Field with Eye Icon Toggle
    /// Used for password and confirm password fields
    private func secureInputField(_ title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            Group {
                if isVisible.wrappedValue {
                    TextField(title, text: text)
                } else {
                    SecureField(title, text: text)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 55)

            // Toggle button for show/hide
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
}

// MARK: - Form Validation Errors
/// Enum used to define custom error messages
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

// MARK: - Hex Color Initializer Extension
extension Color {
    /// Create SwiftUI Color from hex string like "#4F9B75"
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

// MARK: - Live Preview
#Preview {
    SignUpView()
}
