
import SwiftUI

struct CustomTabView: View {
    @State private var selectedTab = 0
    @State private var plannedRecipes: [PlannedRecipe] = []

    var body: some View {
        ZStack {
            // Main Content Area
            Group {
//                if selectedTab == 0 {
//                    HomeView()
//                        .transition(.opacity.combined(with: .scale))
//                } else {
//                    ProfileView()
//                        .transition(.opacity.combined(with: .scale))
//                }
                if selectedTab == 0 {
                     HomeView()
                         .transition(.opacity.combined(with: .scale))
                 } else if selectedTab == 1 {
                     BMIView()
                         .transition(.opacity.combined(with: .scale))
                 } else if selectedTab == 2 {
                     PlannerView(plannedRecipes: $plannedRecipes)
                         .transition(.opacity.combined(with: .scale))
                 } else {
                     ProfileView()
                         .transition(.opacity.combined(with: .scale))
                 }
             }
            .background(
                // Full-screen background gradient behind content
                LinearGradient(colors: [Color(hex: "1B3528"), Color(hex: "4F9B75")],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
        // Custom Capsule Tab Bar
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                Spacer()
                tabBarItem(icon: "house", label: "Home", index: 0)
                Spacer()
                tabBarItem(icon: "heart", label: "BMI", index: 1)
                Spacer()
                tabBarItem(icon: "checklist", label: "Planner", index: 2)
                Spacer()
                tabBarItem(icon: "person", label: "Profile", index: 3)
                Spacer()

            }
            .padding(.vertical, 10)       // ⬆️ Makes the capsule taller
            .padding(.horizontal, 20)     // ⬅️ Adds side spacing
            .background(
                BlurView(style: .systemThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 60, style: .continuous))
            )
            .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
            .padding(.bottom, -20)         // ⬆️ Distance from bottom
            .frame(maxWidth: 370) // 350
            .frame(maxWidth: .infinity, alignment: .center)

        }
    }

    // MARK: - Tab Bar Item
    @ViewBuilder
    func tabBarItem(icon: String, label: String, index: Int) -> some View {
        let isSelected = selectedTab == index

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .bold)) // larger icon
                Text(label)
                    .font(.system(size: 16, weight: .medium)) // larger text
            }
            .foregroundColor(isSelected ? Color(hex: "2E6F40") : Color(hex: "546373").opacity(0.7)) // ✅ Solid green color #6D8196 Color.gray.opacity(0.9)
        }
    }
}
