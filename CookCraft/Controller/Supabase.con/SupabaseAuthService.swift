
import Foundation
import Supabase

// MARK: - Custom Auth Errors
enum CustomAuthError: Error, LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case networkError
    case weakPassword
    case userNotFound
    case accountLocked
    case invalidEmailFormat
    case signUpFailed
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Your email or password is incorrect."
        case .emailAlreadyInUse:
            return "This email is already in use. Try logging in or use a different address."
        case .networkError:
            return "Network error. Please check your connection."
        case .weakPassword:
            return "Your password is too weak. Please choose a stronger password."
        case .userNotFound:
            return "No account found with this email."
        case .accountLocked:
            return "Too many failed attempts. Try again later."
        case .invalidEmailFormat:
            return "Invalid email format. Please check again."
        case .signUpFailed:
            return "Failed to sign up. Please try again."
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Error Mapper
func mapSupabaseError(_ error: Error) -> CustomAuthError {
    let nsError = error as NSError
    let message = nsError.localizedDescription.lowercased()

    if message.contains("invalid login") || message.contains("invalid credentials") {
        return .invalidCredentials
    }
    if message.contains("already registered") || message.contains("email already in use") {
        return .emailAlreadyInUse
    }
    if message.contains("network") || message.contains("internet") || message.contains("connection") {
        return .networkError
    }
    if message.contains("weak password") || message.contains("too short") || message.contains("must contain") {
        return .weakPassword
    }
    if message.contains("user not found") || message.contains("no user") || message.contains("account does not exist") {
        return .userNotFound
    }
    if message.contains("locked") || message.contains("too many attempts") {
        return .accountLocked
    }
    if message.contains("invalid email") || message.contains("email format") || message.contains("not valid") {
        return .invalidEmailFormat
    }
    return .unknown(message: nsError.localizedDescription)
}

@MainActor
final class SupabaseAuthService: ObservableObject {

    // MARK: - Init Client
    // If you prefer, move URL/key to a config file or Info.plist
    private let clientInternal: SupabaseClient
    var client: SupabaseClient { clientInternal }

    @Published var session: Session?
    @Published var user: User?
    @Published var isLoggedIn = false

    init() {
        // Safer URL creation (no force-unwraps)
        guard let url = URL(string: "https://hlskjfdzrvoayettclsn.supabase.co") else {
            fatalError("Invalid Supabase URL")
        }
        clientInternal = SupabaseClient(
            supabaseURL: url,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsc2tqZmR6cnZvYXlldHRjbHNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MDU2NTEsImV4cCI6MjA3NjM4MTY1MX0.oQJ9MI5QzYNj8HnQvN7U_R-0zvjWDrKxZk5ul_8wZ44"
        )

        Task {
            await loadSession()
            await listenForAuthChanges()
        }
    }

    // MARK: - Load Current Session
//    func loadSession() async {
//        do {
//            let session = try await client.auth.session
//            self.session = session
//            self.user = session.user
//            self.isLoggedIn = true
//        } catch {
//            self.session = nil
//            self.user = nil
//            self.isLoggedIn = false
//            print("⚠️ Failed to load session: \(error.localizedDescription)")
//        }
//    }
    func loadSession() async {
        do {
            // Try to load the session
            let session = try await client.auth.session
            
            // If session exists, we load it
            self.session = session
            self.user = session.user
            self.isLoggedIn = true
        } catch {
            // If session retrieval fails (session expired or not found), attempt to refresh it
            print("⚠️ Session not found, attempting to refresh.")
            await refreshSession()
        }
    }

    func refreshSession() async {
        do {
            // Try refreshing the session using the refresh token
            let refreshedSession = try await client.auth.refreshSession()
            self.session = refreshedSession
            self.isLoggedIn = true
        } catch {
            // If refreshing the session fails, clear session and log out the user
            self.session = nil
            self.user = nil
            self.isLoggedIn = false
            print("⚠️ Session refresh failed: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Listen for Auth Changes
    private func listenForAuthChanges() async {
        for await (event, session) in client.auth.authStateChanges {
            switch event {
            case .signedIn:
                print("User signed in")
            case .signedOut:
                print("User signed out")
            default:
                break
            }
            self.session = session
            self.user = session?.user
            self.isLoggedIn = (session != nil)
        }
    }

    // MARK: - Sign Up (Trigger-owned profile creation; no manual insert)
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        do {
            // Pass metadata; DB trigger creates/merges the `profiles` row.
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "first_name": .string(firstName),
                    "last_name": .string(lastName)
                ]
            )

            // Update local state. If confirmations are ON, session will be nil.
            self.user = response.user
            self.session = response.session
            self.isLoggedIn = (response.session != nil)

        } catch {
            throw mapSupabaseError(error)
        }
    }

    // MARK: - Log In
    func logIn(email: String, password: String) async throws {
        do {
            // Current SDK returns Session here
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            self.session = session
            self.user = session.user
            self.isLoggedIn = true
        } catch {
            throw mapSupabaseError(error)
        }
    }
    
    // MARK: - Refresh Session


    // MARK: - Log Out
    func logOut() async throws {
        do {
            try await client.auth.signOut()
            self.session = nil
            self.user = nil
            self.isLoggedIn = false
        } catch {
            throw mapSupabaseError(error)
        }
    }

    // MARK: - Handle Redirect (OAuth / Magic Links)
    func handleRedirect(from url: URL) async {
        client.auth.handle(url)
        do {
            let current = try await client.auth.session
            self.session = current
            self.user = current.user
            self.isLoggedIn = true
        } catch {
            print("⚠️ Failed to refresh session after redirect: \(error.localizedDescription)")
        }
    }
}
