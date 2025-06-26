//
//  UserProfileController.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 25/06/2025.
//

import Foundation
//import FirebaseAuth
//import FirebaseFirestore
import Combine

class UserProfileController:ObservableObject{
    @Published var fullName: String = "Guest"
    @Published var initials: String = "G"
    @Published var email: String = "No email"
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
//    init() {
//        // Observe authentication state changes
//        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
//            if let user = user {
//                self?.fetchUserProfile(userId: user.uid)
//            } else {
//                self?.fullName = "Guest"
//                self?.initials = "G"
//                self?.email = "No email"
//            }
//        }
//    }
    // Fetch user profile data from Firestore
//    private func fetchUserProfile(userId: String) {
//        isLoading = true
//        let db = Firestore.firestore()
//        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
//            self?.isLoading = false
//            if let document = document, document.exists {
//                let data = document.data()
//                let firstName = data?["firstName"] as? String ?? ""
//                let lastName = data?["lastName"] as? String ?? ""
//                let email = data?["email"] as? String ?? "No email"
//                
//                self?.fullName = "\(firstName) \(lastName)"
//                self?.initials = self?.getInitials(firstName: firstName, lastName: lastName) ?? "G"
//                self?.email = email
//                
//            } else {
//                self?.fullName = "Guest"
//                self?.initials = "G"
//                self?.email = "No email"
//            }
//        }
//    }
    
    // Get initials from first and last name
    private func getInitials(firstName: String, lastName: String) -> String {
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
    

    
}
