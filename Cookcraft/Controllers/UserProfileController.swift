//
//  UserProfileController.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 25/06/2025.
//
// MARK: – Controller
import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

// MARK: – Controller
/// Fetches the signed-in user’s Firestore profile (firstName, lastName, email)
class UserProfileController: ObservableObject {
    @Published var fullName: String = "User"
    @Published var initials: String = "U"
    @Published var email: String = "No email"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?     // nil means “no error”

    private var cancellables = Set<AnyCancellable>()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle? // Store the listener handle

    init() {
        // Listen for auth changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.fetchUserProfile(userId: user.uid)
            } else {
                self?.resetToGuest()
            }
        }
    }

    deinit {
        // Remove the auth state listener when the object is deinitialized
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func fetchUserProfile(userId: String) {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("users").document(userId)
          .getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                    self?.resetToGuest()
                    return
                }

                guard
                  let data = snapshot?.data(),
                  let first = data["firstName"] as? String,
                  let last  = data["lastName"]  as? String,
                  let mail  = data["email"]     as? String
                else {
                    self?.errorMessage = "Profile is incomplete."
                    self?.resetToGuest()
                    return
                }

                self?.fullName = "\(first) \(last)"
                self?.initials = Self.makeInitials(firstName: first, lastName: last)
                self?.email    = mail
            }
        }
    }

    private func resetToGuest() {
        fullName = "Guest"
        initials = "G"
        email    = "No email"
    }

    private static func makeInitials(firstName: String, lastName: String) -> String {
        let fi = firstName.first.map(String.init) ?? ""
        let li = lastName.first.map(String.init) ?? ""
        return (fi + li).uppercased()
    }
}
