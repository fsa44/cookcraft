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

// MARK: - Frosted Glass Tile

//struct GlassTileView: View {
//    let icon: String
//    let title: String
//    let subtitle: String
//
//    @State private var isHovered = false
//    @State private var isPressed = false
//
//    var body: some View {
//        HStack(spacing: 16) {
//            Image(systemName: icon)
//                .foregroundColor(.white)
//                .frame(width: 40, height: 40)
//                .background(Color.white.opacity(0.2))
//                .clipShape(Circle())
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.white)
//
//                Text(subtitle)
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//
//            Spacer()
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                .fill(Color.white.opacity(0.15))
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 20)
//                .stroke(Color.white.opacity(0.2), lineWidth: 1)
//        )
//        .scaleEffect(isHovered || isPressed ? 1.03 : 1.0)
//        .animation(.easeInOut(duration: 0.2), value: isHovered || isPressed)
//        .onHover { hovering in
//            isHovered = hovering
//        }
//        .onTapGesture {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                isPressed = true
//            }
//
//            // Reset the pressed state shortly after for the animation effect
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                withAnimation(.easeInOut(duration: 0.2)) {
//                    isPressed = false
//                }
//            }
//        }
//    }
//}

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

// MARK: - Color Hex Extension

//extension Color {
//    /// Initialize a Color from a hex string like "#RRGGBB" or "RRGGBB"
//    init(hexString: String) {
//        let r, g, b: Double
//        
//        var hex = hexString
//        if hex.hasPrefix("#") {
//            hex = String(hex.dropFirst())
//        }
//        
//        if let rgb = UInt64(hex, radix: 16), hex.count == 6 {
//            r = Double((rgb >> 16) & 0xFF) / 255
//            g = Double((rgb >> 8) & 0xFF) / 255
//            b = Double(rgb & 0xFF) / 255
//        } else {
//            // Fallback color in case of invalid hex string
//            r = 0
//            g = 0
//            b = 0
//        }
//        
//        self.init(red: r, green: g, blue: b)
//    }
//}

// MARK: - Preview

#Preview {
    NavigationStack {
        AccountsView()
    }
}
