import SwiftUI

struct DietaryPreferencesWidget: View {
    @State private var isVegetarianOnly = false
    @State private var isVeganOnly = false
    @State private var isPeanutFree = false
    @State private var isTreeNutFree = false
    @State private var isMeatFree = false
    @State private var isDairyFree = false
    @State private var isEggFree = false
    @State private var isGlutenFree = false
    @State private var isWithoutSeafood = false
    @State private var isSugarFree = false
    @State private var isLactoseFreeOnly = false

    var toggleItems: [(title: String, isOn: Binding<Bool>)] {
        return [
            ("Vegetarian only", $isVegetarianOnly),
            ("Vegan only", $isVeganOnly),
            ("Peanut Free", $isPeanutFree),
            ("Tree Nut Free", $isTreeNutFree),
            ("Meat Free", $isMeatFree),
            ("Dairy Free", $isDairyFree),
            ("Egg Free", $isEggFree),
            ("Gluten Free", $isGlutenFree),
            ("Without Seafood", $isWithoutSeafood),
            ("Sugar Free", $isSugarFree),
            ("Lactose Free", $isLactoseFreeOnly)
        ]
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 🌈 Updated Background Gradient (matching ProfileEditorWidget)
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Dietary Preferences")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                            .padding(.top, -10)

                        // 🥗 Dietary Preferences Section
                        Text("Dietary Options")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, -5)
                            .padding(.top, -10)
                        
                        Divider()
                            .background(Color.white.opacity(0.5))
                            .padding(.bottom, 4)
                            .padding(.top, -20)

                        ForEach(toggleItems, id: \.title) { item in
                            ToggleRow(title: item.title, isOn: item.isOn)
                                .padding(.vertical, 10)
                        }
                        .padding(.top, -20)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ToggleRow: View {
    var title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DietaryPreferencesWidget()
    }
}
