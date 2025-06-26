//
//  VersionView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 25/06/2025.
//

// Make updates too ensure dynamic.
//  VersionView.swift


import SwiftUI

struct VersionView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    private let environment = "Development" // Change as needed (e.g., "Staging", "Development")

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("App Version Info")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)

                GlassTileView(icon: "number.circle.fill", title: "Version", subtitle: appVersion)
                GlassTileView(icon: "hammer.circle.fill", title: "Build", subtitle: buildNumber)
                GlassTileView(icon: "network", title: "Environment", subtitle: environment)

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack (spacing: 10){
                    Spacer(minLength: 50) // Space above "Account"
                    Text("Version")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer(minLength: 20) // Space below "Account"
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VersionView()
    }
}
