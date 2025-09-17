//
//  AccountsView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 25/06/2025.
//

//Maybe Code
//

import SwiftUI

struct AccountsView: View {
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hexString: "#63AD7A"), Color(hexString: "#0A3D2F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(accountItems, id: \.self) { item in
                        GlassTileView(icon: item.icon, title: item.title, subtitle: item.subtitle)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack (spacing: 10){
                    Spacer(minLength: 50) // Space above "Account"
                    Text("Account")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer(minLength: 40) // Space below "Account"
                }
            }
        }
    }
}


// MARK: - Mock Data

struct AccountItem: Hashable {
    let icon: String
    let title: String
    let subtitle: String
}

let accountItems: [AccountItem] = [
    AccountItem(icon: "person.crop.circle", title: "Personal Info", subtitle: "Update your details"),
    AccountItem(icon: "lock.circle", title: "Security", subtitle: "Change password, enable 2FA"),
    AccountItem(icon: "bell.circle", title: "Notifications", subtitle: "Manage notification settings"),
    AccountItem(icon: "creditcard.circle", title: "Billing", subtitle: "View invoices and payment methods"),
    AccountItem(icon: "doc.text", title: "Documents", subtitle: "Manage your uploaded documents")
]



// MARK: - Preview

#Preview {
    NavigationStack {
        AccountsView()
    }
}
