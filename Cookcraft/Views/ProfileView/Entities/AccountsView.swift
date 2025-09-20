import SwiftUI

struct AccountsView: View {
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
    @State private var selectedLanguage = "English"
    
    // State to show or hide the popup
    @State private var showPopup = false

    // Define the list of toggle items using a computed property
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
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hexString: "#63AD7A"), Color(hexString: "#0A3D2F")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()  // Make sure gradient covers the entire screen

                // ScrollView to make the content scrollable
                ScrollView {
                    VStack {
                        Text("Account")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
//                            .padding(.top, -20)
                            .padding(.bottom, 40)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Premium Button
                        HStack {
                            // Premium Text aligned to the left
                            Text("Premium")
                                .foregroundColor(.white)
//                                .fontWeight(.bold)

                                .frame(maxWidth: .infinity, alignment: .leading) // Ensures the text stays aligned to the left
                            
                            // Spacer to push the "Activate" button to the far right
                            Spacer()
                            
                            // Activate Button
                            Button(action: {
                                // Activate premium action
                                // Toggle the popup visibility when the button is pressed
                                showPopup.toggle()
                            }) {
                                Text("Activate")
                                    .padding()
                                    .padding(.horizontal, 35)
                                    .padding(.vertical, -4.5)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(45)
                            }
                        }
                        .padding(.top, -25)  // Apply negative top padding
                        .padding(.bottom, 35) // Apply bottom padding

                                    
                        // Dietary Preferences Title
                        Text("Dietary Preferences")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                        // List of toggle items
                        ForEach(toggleItems, id: \.title) { item in
                            ToggleRow(title: item.title, isOn: item.isOn)
                                .padding(.vertical, 5)
                        }
                    }
                    .padding(.horizontal)
                }
                // Show the popup when 'showPopup' is true
                if showPopup {
                    PremiumPopupView(showPopup: $showPopup)
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
            Toggle(isOn: $isOn) {
                Text("")
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.green))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AccountsView()
    }
}
