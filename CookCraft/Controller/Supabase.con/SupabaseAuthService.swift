//


import Foundation
import Supabase

// MARK: - Custom Auth Errors (unchanged)
enum CustomAuthError: Error, LocalizedError {
    case invalidCredentials, emailAlreadyInUse, networkError, weakPassword, userNotFound,
         accountLocked, invalidEmailFormat, signUpFailed, unknown(message: String)
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:  return "Your email or password is incorrect."
        case .emailAlreadyInUse:   return "This email is already in use. Try logging in or use a different address."
        case .networkError:        return "Network error. Please check your connection."
        case .weakPassword:        return "Your password is too weak. Please choose a stronger password."
        case .userNotFound:        return "No account found with this email."
        case .accountLocked:       return "Too many failed attempts. Try again later."
        case .invalidEmailFormat:  return "Invalid email format. Please check again."
        case .signUpFailed:        return "Failed to sign up. Please try again."
        case .unknown(let msg):    return msg
        }
    }
}

func mapSupabaseError(_ error: Error) -> CustomAuthError {
    let ns = error as NSError
    let msg = ns.localizedDescription.lowercased()
    if msg.contains("invalid login") || msg.contains("invalid credentials") { return .invalidCredentials }
    if msg.contains("already registered") || msg.contains("email already in use") { return .emailAlreadyInUse }
    if msg.contains("network") || msg.contains("internet") || msg.contains("connection") { return .networkError }
    if msg.contains("weak password") || msg.contains("too short") { return .weakPassword }
    if msg.contains("user not found") || msg.contains("no user") { return .userNotFound }
    if msg.contains("locked") || msg.contains("too many attempts") { return .accountLocked }
    if msg.contains("invalid email") || msg.contains("email format") { return .invalidEmailFormat }
    return .unknown(message: ns.localizedDescription)
}

@MainActor
final class SupabaseAuthService: ObservableObject {
    // Use the shared client we configured
    var client: SupabaseClient { supabase }

    @Published var session: Session?
    @Published var user: User?
    @Published var isLoggedIn = false

    init() {
        Task {
            await loadSession()
            await listenForAuthChanges()
        }
    }

    // MARK: - Session
    func loadSession() async {
        do {
            let s = try await client.auth.session
            self.session = s
            self.user = s.user
            self.isLoggedIn = true
        } catch {
            // try refresh if supported
            await refreshSession()
        }
    }

    func refreshSession() async {
        do {
            let s = try await client.auth.refreshSession()
            self.session = s
            self.user = s.user
            self.isLoggedIn = true
        } catch {
            self.session = nil
            self.user = nil
            self.isLoggedIn = false
            print("⚠️ Session refresh failed: \(error.localizedDescription)")
        }
    }

    private func listenForAuthChanges() async {
        for await (event, session) in client.auth.authStateChanges {
            switch event {
            case .signedIn:  print("✅ signed in")
            case .signedOut: print("🚪 signed out")
            default: break
            }
            self.session = session
            self.user = session?.user
            self.isLoggedIn = (session != nil)
        }
    }

    // MARK: - Auth
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        do {
            let resp = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["first_name": .string(firstName), "last_name": .string(lastName)]
            )
            self.user = resp.user
            self.session = resp.session
            self.isLoggedIn = (resp.session != nil)
        } catch { throw mapSupabaseError(error) }
    }

    func logIn(email: String, password: String) async throws {
        do {
            let s = try await client.auth.signIn(email: email, password: password)
            self.session = s
            self.user = s.user
            self.isLoggedIn = true
        } catch { throw mapSupabaseError(error) }
    }

    func logOut() async throws {
        do {
            try await client.auth.signOut()
            self.session = nil
            self.user = nil
            self.isLoggedIn = false
        } catch { throw mapSupabaseError(error) }
    }

    func handleRedirect(from url: URL) async {
        client.auth.handle(url)
        do {
            let s = try await client.auth.session
            self.session = s
            self.user = s.user
            self.isLoggedIn = true
        } catch {
            print("⚠️ redirect session load failed: \(error.localizedDescription)")
        }
    }
}
