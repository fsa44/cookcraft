import SwiftUI

struct MealPlannerView: View {
    @State private var bmi: Double = 22.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Input Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Adjust Your Preferences")
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        HStack {
                            Text("BMI: \(String(format: "%.1f", bmi))")
                                .foregroundColor(.white)
                            Slider(value: $bmi, in: 10...40, step: 0.1)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)

                    // MARK: - Dynamic Meal Sections
                    ForEach(generateMealSections(), id: \.title) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.title)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading, 4)

                            ForEach(section.items, id: \.self) { item in
                                GlassTileView(
                                    icon: item.icon,
                                    title: item.name,
                                    subtitle: item.description
                                )
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 10) {
                    Spacer(minLength: 50)
                    Text("Meal Planner")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer(minLength: 40)
                }
            }
        }
    }

    // MARK: - Dynamic Meal Section Generator

    func generateMealSections() -> [MealSection] {
        let hour = Calendar.current.component(.hour, from: Date())
        var sections: [MealSection] = []

        if hour < 11 {
            sections.append(MealSection(title: "Breakfast", items: generateMeals(for: "breakfast")))
        }
        if hour >= 11 && hour < 17 {
            sections.append(MealSection(title: "Lunch", items: generateMeals(for: "lunch")))
        }
        if hour >= 17 {
            sections.append(MealSection(title: "Dinner", items: generateMeals(for: "dinner")))
        }

        return sections
    }

    func generateMeals(for type: String) -> [MealItem] {
        switch type {
        case "breakfast":
            if bmi < 18.5 {
                return [
                    MealItem(icon: "sunrise.fill", name: "Avocado Toast", description: "With poached eggs"),
                    MealItem(icon: "sunrise.fill", name: "Peanut Butter Oats", description: "Topped with bananas")
                ]
            } else if bmi < 25 {
                return [
                    MealItem(icon: "sunrise.fill", name: "Oatmeal", description: "With berries and almonds"),
                    MealItem(icon: "sunrise.fill", name: "Smoothie", description: "Spinach, banana, protein")
                ]
            } else {
                return [
                    MealItem(icon: "sunrise.fill", name: "Boiled Eggs", description: "Low-carb, with greens"),
                    MealItem(icon: "sunrise.fill", name: "Low-fat Yogurt", description: "With chia seeds")
                ]
            }

        case "lunch":
            if bmi < 18.5 {
                return [
                    MealItem(icon: "fork.knife", name: "Chicken Burrito", description: "With rice and beans"),
                    MealItem(icon: "fork.knife", name: "Pasta Primavera", description: "Creamy, veggie-loaded")
                ]
            } else if bmi < 25 {
                return [
                    MealItem(icon: "fork.knife", name: "Grilled Chicken", description: "With quinoa and veggies"),
                    MealItem(icon: "fork.knife", name: "Veggie Wrap", description: "Hummus, spinach, tomato")
                ]
            } else {
                return [
                    MealItem(icon: "fork.knife", name: "Tuna Salad", description: "With olive oil dressing"),
                    MealItem(icon: "fork.knife", name: "Stuffed Peppers", description: "Quinoa and turkey")
                ]
            }

        case "dinner":
            if bmi < 18.5 {
                return [
                    MealItem(icon: "moon.stars.fill", name: "Steak Bowl", description: "Brown rice and avocado"),
                    MealItem(icon: "moon.stars.fill", name: "Cheesy Lasagna", description: "With lean beef")
                ]
            } else if bmi < 25 {
                return [
                    MealItem(icon: "moon.stars.fill", name: "Salmon Bowl", description: "Brown rice, avocado, greens"),
                    MealItem(icon: "moon.stars.fill", name: "Tofu Stir-Fry", description: "Broccoli, carrots, soy sauce")
                ]
            } else {
                return [
                    MealItem(icon: "moon.stars.fill", name: "Grilled Veggies", description: "With tofu or tempeh"),
                    MealItem(icon: "moon.stars.fill", name: "Zucchini Noodles", description: "Pesto, cherry tomatoes")
                ]
            }

        default:
            return []
        }
    }

    // MARK: - Models

    struct MealItem: Hashable {
        let icon: String
        let name: String
        let description: String
    }

    struct MealSection: Hashable {
        let title: String
        let items: [MealItem]
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MealPlannerView()
    }
}

// MARK: - Placeholder GlassTileView

struct GlassTileView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .padding()
                .background(.ultraThinMaterial, in: Circle())

            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
