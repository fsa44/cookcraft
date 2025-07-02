import SwiftUI

// Main View for Meal Planner screen
struct MealPlannerView: View {
    // State variable to hold the current BMI value, adjustable via slider
    @State private var bmi: Double = 22.0
    
    var body: some View {
        ZStack {
            // Background gradient from green (#63AD7A) to darker green (#0A3D2F)
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#63AD7A"), Color(hex: "#0A3D2F")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Extend gradient to fill entire screen
            
            // Scrollable container for all content, supports vertical scrolling
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Input Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Section header text
                        Text("Adjust Your Preferences")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        
                        // Horizontal stack for BMI label and slider
                        HStack {
                            // Display current BMI with 1 decimal place
                            Text("BMI: \(String(format: "%.1f", bmi))")
                                .foregroundColor(.white)
                            // Slider to adjust BMI value within 10 to 40 range, step 0.1
                            Slider(value: $bmi, in: 10...40, step: 0.1)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial) // Blurred translucent background material
                    .cornerRadius(12) // Rounded corners for input container
                    
                    // MARK: - Dynamic Meal Sections
                    // Generate meal sections dynamically based on current time and BMI
                    ForEach(generateMealSections(), id: \.title) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            // Section title (e.g., Breakfast, Lunch, Dinner)
                            Text(section.title)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading, 4)
                            
                            // For each meal item in this section, create a glass tile view
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
                .padding() // Padding around entire VStack content
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Use inline navigation bar style
        .toolbar {
            // Toolbar content with title centered
            ToolbarItem(placement: .principal) {
                VStack(spacing: 10) {
                    Spacer(minLength: 50) // Add vertical spacing above title
                    Text("Meal Planner")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Spacer(minLength: 40) // Add vertical spacing below title
                }
            }
        }
    }
    
    // MARK: - Dynamic Meal Section Generator
    
    /// Generates meal sections (Breakfast, Lunch, Dinner) based on current hour.
    /// Only shows relevant meals depending on time of day.
    func generateMealSections() -> [MealSection] {
        let hour = Calendar.current.component(.hour, from: Date()) // Get current hour (0-23)
        var sections: [MealSection] = []
        
        // If before 11 AM, show Breakfast section
        if hour < 11 {
            sections.append(MealSection(title: "Breakfast", items: generateMeals(for: "breakfast")))
        }
        // If between 11 AM and 5 PM, show Lunch section
        if hour >= 11 && hour < 17 {
            sections.append(MealSection(title: "Lunch", items: generateMeals(for: "lunch")))
        }
        // If 5 PM or later, show Dinner section
        if hour >= 17 {
            sections.append(MealSection(title: "Dinner", items: generateMeals(for: "dinner")))
        }
        
        return sections
    }
    
    /// Returns an array of MealItem objects customized by meal type and BMI.
    /// Different meal suggestions for underweight, normal, and overweight categories.
    func generateMeals(for type: String) -> [MealItem] {
        switch type {
        case "breakfast":
            if bmi < 18.5 { // Underweight suggestions
                return [
                    MealItem(icon: "sunrise.fill", name: "Avocado Toast", description: "With poached eggs"),
                    MealItem(icon: "sunrise.fill", name: "Peanut Butter Oats", description: "Topped with bananas")
                ]
            } else if bmi < 25 { // Normal weight suggestions
                return [
                    MealItem(icon: "sunrise.fill", name: "Oatmeal", description: "With berries and almonds"),
                    MealItem(icon: "sunrise.fill", name: "Smoothie", description: "Spinach, banana, protein")
                ]
            } else { // Overweight suggestions
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
            return [] // Return empty list if meal type unknown
        }
    }
    
    // MARK: - Data Models
    
    // Model representing an individual meal suggestion item
    struct MealItem: Hashable {
        let icon: String       // SF Symbol icon name
        let name: String       // Meal name/title
        let description: String // Short meal description
    }
    
    // Model representing a meal section (Breakfast, Lunch, Dinner) containing multiple meal items
    struct MealSection: Hashable {
        let title: String          // Section title
        let items: [MealItem]      // Array of meals in this section
    }
}

// MARK: - Preview

// NavigationStack wraps the MealPlannerView to provide navigation bar support
#Preview {
    NavigationStack {
        MealPlannerView()
    }
}

// MARK: - Placeholder GlassTileView

// Simple reusable tile view with blurred background for each meal item
struct GlassTileView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            // Icon in a circle with blurred glass effect background
            Image(systemName: icon)
                .font(.title2)
                .padding()
                .background(.ultraThinMaterial, in: Circle())
            
            // Title and subtitle stacked vertically aligned to leading edge
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
            }
            
            Spacer() // Pushes content to left, fills remaining space
        }
        .padding() // Padding inside tile
        .background(.ultraThinMaterial) // Blurred translucent background
        .cornerRadius(12) // Rounded corners
        .shadow(radius: 3) // Soft shadow for depth
    }
}
