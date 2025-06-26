//
//  SignUpView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//

import SwiftUI

struct SignUpView: View {
    // MARK: - Form Fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    // MARK: - UI State Management
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false

    // MARK: - Password Visibility Toggles
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "1B3528"), Color(hex: "4F9B75")]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // MARK: - Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sign Up")
                            .font(.title) // Reduced from .largeTitle
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Cookcraft.")
                            .font(.custom("Avenir", size: 67))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 10)

                    // MARK: - Form Section
                    Section(header:
                        Text("Enter Details")
                            .font(.custom("Avenir", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                    ) {
                        // Input fields for user details
                        inputField("First Name", text: $firstName)
                        inputField("Last Name", text: $lastName)
                        inputField("Email", text: $email, isEmail: true)
                        secureInputField("Password", text: $password, isVisible: $showPassword)
                        secureInputField("Confirm Password", text: $confirmPassword, isVisible: $showConfirmPassword)
                    }

                    // MARK: - Sign Up Button or Loading Indicator
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

                    // MARK: - Navigation to Home (post signup)
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    // MARK: - Custom Input Fields

    /// A generic text field for user input.
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

    /// A secure field with toggleable visibility for password input.
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

            Button(action: {
                isVisible.wrappedValue.toggle()
            }) {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
    }

    // MARK: - Sign Up Logic

    /// Handles the signup action with basic validation and simulated async delay.
    private func signUp() {
        do {
            try validateForm()
            isLoading = true

            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isLoading = false
                alertMessage = "Welcome to CookCraft, \(firstName)."
                showAlert = true
                navigateToHome = true
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    /// Validates user input fields using regex and logical checks.
    private func validateForm() throws {
        let nameRegex = "^[ a-zA-Z]+(?:[\\s-][a-zA-Z]+)*$"
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let passwordRegex = #"^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"#

        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        guard namePredicate.evaluate(with: "\(firstName) \(lastName)") else {
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
}

// MARK: - Hex Color Extension

extension Color {
    /// Initializes a Color from a hex string (e.g., "4F9B75")
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

// MARK: - Error Handling

/// Enum representing validation errors in the sign-up form.
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
            return "Password must be at least 8 characters and include a letter, a number, and a special character."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        }
    }
}

// MARK: - Preview

#Preview {
    SignUpView()
}
