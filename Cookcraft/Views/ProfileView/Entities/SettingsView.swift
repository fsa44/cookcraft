//
//  SettingsView.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 25/06/2025.
//

//
//  SettingsView.swift
// Check this out

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedLanguage = "English"

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {

                    // MARK: - Language Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Language")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.leading, 4)

                        GlassTileView(icon: "globe", title: "App Language", subtitle: selectedLanguage)
                            .contextMenu {
                                Button("English") { selectedLanguage = "English" }
                                Button("Spanish") { selectedLanguage = "Spanish" }
                                Button("French") { selectedLanguage = "French" }
                            }
                    }

                    // MARK: - Appearance Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appearance")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.leading, 4)

                        Toggle(isOn: $isDarkMode) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.white)
                                Text("Dark Mode")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.white.opacity(0.15))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                    }

                    // MARK: - Support Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Support")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.leading, 4)

                        ForEach(supportItems, id: \.self) { item in
                            GlassTileView(icon: item.icon, title: item.title, subtitle: item.description)
                                .onTapGesture {
                                    // Placeholder for navigation or modal presentation
                                    print("\(item.title) tapped")
                                }
                        }
                    }

                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack (spacing: 10){
                    Spacer(minLength: 50) // Space above "Account"
                    Text("Settings")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer(minLength: 40) // Space below "Account"
                }
            }
        }
    }
}

//        .navigationTitle("")
//        .navigationBarTitleDisplayMode(.inline)
//
//    }
//}

// MARK: - Support Item Model

struct SupportItem: Hashable {
    let icon: String
    let title: String
    let description: String
}

let supportItems: [SupportItem] = [
    SupportItem(icon: "questionmark.circle.fill", title: "Help Centre", description: "FAQs and support articles"),
    SupportItem(icon: "doc.text.fill", title: "Terms of Service", description: "Read our usage terms"),
    SupportItem(icon: "hand.raised.fill", title: "Privacy Policy", description: "How we protect your data"),
    SupportItem(icon: "info.circle.fill", title: "App Info", description: "Version 1.0.0")
]

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
}
