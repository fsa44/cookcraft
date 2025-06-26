//
//  LogInView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//

import SwiftUI

struct LogInView: View {
    // MARK: - Form Fields
    @State private var email: String = ""
    @State private var password: String = ""

    // MARK: - UI State Management
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false

    // MARK: - Password Visibility Toggle
    @State private var showPassword: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "63AD7A"), Color(hex: "193125")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

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

                    // MARK: - Form Section
                    Section(header:
                        Text("Enter Details")
                            .font(.custom("Avenir", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                    ) {
                        inputField("Email", text: $email, isEmail: true)
                        secureInputField("Password", text: $password, isVisible: $showPassword)
                    }

                    // MARK: - Log In Button or Loading Indicator
                    if isLoading {
                        ProgressView().padding()
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

                    // MARK: - Navigation to Sign Up
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                    }

                    // MARK: - Navigation to Home (post login)
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView()
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Log In"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    // MARK: - Custom Input Fields

    /// A generic text field for email input.
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

    // MARK: - Log In Logic

    /// Handles the login action with basic validation and simulated async delay.
    private func logIn() {
        do {
            try validateForm()
            isLoading = true

            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isLoading = false
                alertMessage = "Welcome back to CookCraft!"
                showAlert = true
                navigateToHome = true
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    /// Validates login input fields using regex and logic.
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
}

// MARK: - Login Validation Errors

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

// MARK: - Hex Color Extension

extension Color {
    init(hexString: String) {
        let scanner = Scanner(string: hexString)
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
    LogInView()
}
