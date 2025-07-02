//
//  LogInView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//

import SwiftUI

// MARK: - Main Login View
struct LogInView: View {

    // MARK: - User Input State Variables
    @State private var email: String = ""           // Stores user's email input
    @State private var password: String = ""        // Stores user's password input

    // MARK: - UI Control State Variables
    @State private var isLoading: Bool = false      // Indicates if a login is in progress (shows spinner)
    @State private var showAlert: Bool = false      // Triggers the display of the alert
    @State private var alertMessage: String = ""    // Stores alert message content
    @State private var navigateToHome: Bool = false // Controls navigation to the Home screen after login

    // MARK: - Password Visibility Toggle
    @State private var showPassword: Bool = false   // Toggles password visibility in the password field

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Gradient Setup
                LinearGradient(gradient: Gradient(colors: [Color(hex: "63AD7A"), Color(hex: "193125")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea() // Extends background across screen edges

                VStack(spacing: 20) {
                    // MARK: - Branding Section
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

                    // MARK: - Form Header & Fields
                    Section(header:
                        Text("Enter Details")
                            .font(.custom("Avenir", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                    ) {
                        inputField("Email", text: $email, isEmail: true)                  // Email input field
                        secureInputField("Password", text: $password, isVisible: $showPassword) // Password input with visibility toggle
                    }

                    // MARK: - Log In Button or Loading Indicator
                    if isLoading {
                        ProgressView().padding() // Show loading spinner when login is in progress
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

                    // MARK: - Navigation Link to Sign Up Screen
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                    }

                    // MARK: - Navigation to Home on Successful Login
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Log In"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }

    // MARK: - Custom Email Input Field Generator
    /// Creates a styled input field for text or email input
    private func inputField(_ title: String, text: Binding<String>, isEmail: Bool = false) -> some View {
        TextField(title, text: text)
            .padding(.horizontal, 10)
            .frame(height: 55)
            .background(Color(.systemGray6)) // Light gray background
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1)) // Gray border
            .autocapitalization(isEmail ? .none : .words)
            .keyboardType(isEmail ? .emailAddress : .default)
            .disableAutocorrection(true)
    }

    // MARK: - Custom Password Input Field with Visibility Toggle
    /// Creates a password input field with an "eye" button to toggle visibility
    private func secureInputField(_ title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            Group {
                if isVisible.wrappedValue {
                    TextField(title, text: text) // Show password as plain text
                } else {
                    SecureField(title, text: text) // Obscure password
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 55)

            Button(action: {
                isVisible.wrappedValue.toggle() // Toggle password visibility
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

    // MARK: - Login Action Handler
    /// Validates form, simulates login delay, and shows alert
    private func logIn() {
        do {
            try validateForm() // Validate user input
            isLoading = true   // Show loading indicator

            // Simulated network delay (e.g. API call)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isLoading = false
                alertMessage = "Welcome back to CookCraft!"
                showAlert = true
                navigateToHome = true // Navigate to home on success
            }
        } catch {
            alertMessage = error.localizedDescription // Show error alert
            showAlert = true
        }
    }

    // MARK: - Input Validation Logic
    /// Checks email format and non-empty password
    private func validateForm() throws {
        // Regular expression for email validation
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard emailPredicate.evaluate(with: email) else {
            throw LogInError.invalidEmail
        }

        guard !password.isEmpty else {
            throw LogInError.invalidPassword
        }
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
