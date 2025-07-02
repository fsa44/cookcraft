//
//  SignUpView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//

import SwiftUI

// MARK: - Main Sign Up View
struct SignUpView: View {

    // MARK: - User Input Fields
    @State private var firstName: String = ""            // User's first name
    @State private var lastName: String = ""             // User's last name
    @State private var email: String = ""                // User's email
    @State private var password: String = ""             // Password field
    @State private var confirmPassword: String = ""      // Confirm password field

    // MARK: - UI State Management
    @State private var isLoading: Bool = false           // Whether to show loading indicator
    @State private var showAlert: Bool = false           // Toggle alert visibility
    @State private var alertMessage: String = ""         // Message shown in alert
    @State private var navigateToHome: Bool = false      // Controls navigation to home screen after signup

    // MARK: - Password Visibility Toggles
    @State private var showPassword: Bool = false        // Toggle password visibility
    @State private var showConfirmPassword: Bool = false // Toggle confirm password visibility

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "1B3528"), Color(hex: "4F9B75")]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea() // Extends gradient to entire screen

                VStack(spacing: 20) {

                    // MARK: - Title / Branding
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

                    // MARK: - Sign Up Button / Progress Indicator
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

                    // MARK: - Navigation to Login View
                    NavigationLink(destination: LogInView()) {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.white)
                    }

                    // MARK: - Navigation to Home View (Post Signup)
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                    }
                }
                .padding()
                // Alert shown after validation error or signup success
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

    // MARK: - Reusable Input Field
    /// Text input field with styling, supports email and text modes
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

    // MARK: - Secure Password Field with Visibility Toggle
    private func secureInputField(_ title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            Group {
                if isVisible.wrappedValue {
                    TextField(title, text: text) // Show plain text
                } else {
                    SecureField(title, text: text) // Hide characters
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 55)

            // Eye icon toggles password visibility
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

    // MARK: - Sign Up Action Logic
    private func signUp() {
        do {
            try validateForm() // Perform form validation
            isLoading = true

            // Simulate API delay
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

    // MARK: - Input Validation
    /// Validates all fields with regex and logical checks
    private func validateForm() throws {
        // Regex patterns
        let nameRegex = "^[ a-zA-Z]+(?:[\\s-][a-zA-Z]+)*$" // Validates first and last name (letters only)
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$" // Standard email format
        let passwordRegex = #"^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"# // Password must contain 1 letter, 1 digit, 1 special character

        // Predicates for validation
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        // Validation checks
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
    /// Initialize SwiftUI Color from hex string (e.g., "#4F9B75")
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // Skip hash symbol
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Error Handling for Validation Failures
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
