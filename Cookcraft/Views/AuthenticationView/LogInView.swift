//
//  LogInView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//  Updated by ChatGPT on 02/07/2025.
//

import SwiftUI
import FirebaseAuth

// MARK: - Main Login View
struct LogInView: View {

    // MARK: - User Input State Variables
    @State private var email: String = ""
    @State private var password: String = ""

    // MARK: - UI Control State Variables
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false

    // MARK: - Password Visibility Toggle
    @State private var showPassword: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "63AD7A"), Color(hex: "193125")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Branding
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Log In")
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
                    Section(header: Text("Enter Details")
                                .font(.custom("Avenir", size: 18))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                    ) {
                        inputField("Email", text: $email, isEmail: true)
                        secureInputField("Password", text: $password, isVisible: $showPassword)
                    }

                    // Log In Button / Spinner
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Button(action: logIn) {
                            Text("Log In")
                                .frame(width: 260, height: 58)
                                .background(Color(hex: "2D8E6D"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }

                    // Sign Up Link
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                    }
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Log In Error"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }

    // MARK: - Login Action Handler
    private func logIn() {
        do {
            try validateForm()
            isLoading = true

            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                DispatchQueue.main.async {
                    isLoading = false

                    if let error = error as NSError? {
                        // Handle specific Firebase Auth errors if needed
                        alertMessage = firebaseErrorMessage(from: error)
                        showAlert = true
                    } else {
                        // Successful login
                        navigateToHome = true
                    }
                }
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    // MARK: - Input Validation Logic
    private func validateForm() throws {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            throw LogInError.invalidEmail
        }
        guard !password.isEmpty else {
            throw LogInError.invalidPassword
        }
    }

    // MARK: - Map Firebase Errors to User-Friendly Messages
    private func firebaseErrorMessage(from error: NSError) -> String {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return error.localizedDescription
        }
        switch code {
        case .invalidEmail:
            return "The email address is badly formatted."
        case .userDisabled:
            return "This account has been disabled. Please contact support."
        case .wrongPassword:
            return "The password is incorrect. Please try again."
        case .userNotFound:
            return "No account found with this email."
        case .networkError:
            return "Network error. Please check your internet connection and try again."
        default:
            return error.localizedDescription
        }
    }

    // MARK: - Custom Email Input Field
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

    // MARK: - Custom Password Input Field
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

// MARK: - Custom Error Enum for Login Validation
enum LogInError: Error, LocalizedError {
    case invalidEmail
    case invalidPassword

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidPassword:
            return "Password field cannot be empty."
        }
    }
}

// MARK: - Extension for Hex Color Initialization
extension Color {
    /// Initializes a SwiftUI Color using a hex string (e.g., "63AD7A")
    init(hexString: String) {
        let scanner = Scanner(string: hexString)
        _ = scanner.scanString("#") // Skip '#' if present
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}


// MARK: - Preview Provider
#Preview {
    LogInView()
}
