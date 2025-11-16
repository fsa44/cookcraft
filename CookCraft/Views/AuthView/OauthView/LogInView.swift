
import SwiftUI
import Supabase

struct LogInView: View {

    @EnvironmentObject var auth: SupabaseAuthService
    // MARK: - User Input
    @State private var email: String = ""
    @State private var password: String = ""

    // MARK: - UI State
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToHome: Bool = false
    @State private var showPassword: Bool = false

    // Suspension banner
    @State private var showSuspensionBanner: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "63AD7A"), Color(hex: "193125"),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    // MARK: - Branding
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
                    .padding(.bottom, 140)

                    // MARK: - Input Fields
                    Section(
                        header: Text("Enter Details")
                            .font(.custom("Avenir", size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                    ) {
                        inputField("Email", text: $email, isEmail: true)
                        secureInputField("Password", text: $password, isVisible: $showPassword)
                    }

                    // MARK: - Login Button or Spinner
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Button {
                            Task {
                                await logIn()
                            }
                        } label: {
                            Text("Log In")
                                .frame(width: 260, height: 58)
                                .background(isFormValid ? Color(hex: "2D8E6D") : Color.gray.opacity(0.55))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 10)
                    }

                    // MARK: - Sign Up Navigation
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .foregroundColor(.white)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 80)

                    // Navigate on success
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

                // MARK: - Suspension Banner Toast
                if showSuspensionBanner {
                    VStack {
                        HStack(alignment: .center, spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.white)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Account Suspended")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Your account has been suspended. Please contact CookCraft support for help.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.80, green: 0.20, blue: 0.20),
                                    Color(red: 0.45, green: 0.10, blue: 0.10)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 16)
                        .padding(.top, 50)

                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: showSuspensionBanner)
                }
            }
        }
    }

    // MARK: - Button changing color state
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    // MARK: - Login Logic with SupabaseAuthService + suspension check
    @MainActor
    private func logIn() async {
        do {
            try validateForm()
            isLoading = true
            showSuspensionBanner = false

            // 1) Ask the shared auth service to log in
            try await auth.logIn(email: email.lowercased(), password: password)

            // 2) If successful and not suspended, auth.isLoggedIn will be true
            if auth.isLoggedIn {
                navigateToHome = true
            }

        } catch let error as LogInError {
            // Validation errors (your own)
            alertMessage = error.localizedDescription
            showAlert = true

        } catch let error as CustomAuthError {
            // Auth service errors (including suspension)
            alertMessage = error.localizedDescription
            showAlert = true

            if case .suspendedAccount = error {
                // Show CookCraft suspension banner
                showSuspensionBanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        showSuspensionBanner = false
                    }
                }
            }

        } catch {
            // Any other unknown error
            alertMessage = error.localizedDescription
            showAlert = true
        }

        isLoading = false
    }



    // MARK: - Input Validation
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

    // MARK: - Fields (unchanged)
    private func inputField(
        _ title: String,
        text: Binding<String>,
        isEmail: Bool = false
    ) -> some View {
        TextField(title, text: text)
            .padding(.horizontal, 10)
            .frame(height: 55)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1)
            )
            .autocapitalization(isEmail ? .none : .words)
            .keyboardType(isEmail ? .emailAddress : .default)
            .disableAutocorrection(true)
    }

    private func secureInputField(
        _ title: String,
        text: Binding<String>,
        isVisible: Binding<Bool>
    ) -> some View {
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
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1)
        )
    }
}

// MARK: - Login Input Validation Errors
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

#Preview {
    LogInView()
        .environmentObject(SupabaseAuthService())
}
