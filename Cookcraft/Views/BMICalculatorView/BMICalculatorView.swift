import SwiftUI
import Charts

// Main View struct for the BMI Calculator app
struct BMICalculatorView: View {
    // MARK: - State properties to store user inputs and results
    @State private var age: String = ""           // Stores age input as a string
    @State private var weight: String = ""        // Stores weight input as a string
    @State private var height: String = ""        // Stores height input as a string
    @State private var bmiResult: String = ""     // Stores formatted BMI result text
    @State private var bmiValue: Double = 0       // Stores numeric BMI value for chart & logic
    @State private var selectedGender: Gender? = nil // Stores selected gender (optional)

    // Enum to represent gender selection with two cases
    enum Gender {
        case male, female
    }

    // The body property builds the UI view hierarchy
    var body: some View {
        ZStack {
            // Background gradient spanning from green (top) to black (bottom)
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all) // Make gradient cover entire screen

            VStack(spacing: 20) { // Vertical stack to arrange elements with spacing
                // Title of the screen
                Text("BMI Calculator")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()

                // Gender selection buttons arranged horizontally
                HStack(spacing: 30) {
                    // Male button
                    Button(action: { selectedGender = .male }) {
                        VStack {
                            Image(systemName: "male")  // Male symbol icon
                            Text("Male")               // Label below icon
                        }
                        .padding()
                        // Highlight button background green if selected, else gray
                        .background(selectedGender == .male ? Color.green : Color.gray.opacity(0.6))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }

                    // Female button (similar styling to male)
                    Button(action: { selectedGender = .female }) {
                        VStack {
                            Image(systemName: "female")
                            Text("Female")
                        }
                        .padding()
                        .background(selectedGender == .female ? Color.green : Color.gray.opacity(0.6))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }
                }

                // BMI chart view that dynamically reflects bmiValue
                BMIChartView(bmiValue: bmiValue)
                    .frame(height: 200) // Fixed height for chart container

                // VStack for input fields and calculate button
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        // Age input field - number pad keyboard
                        TextField("Age", text: $age)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)  // Only numbers
                            .foregroundColor(.white)
                            .accentColor(.green)      // Cursor color

                        // Weight input field - decimal pad keyboard with "kg" overlay
                        TextField("Weight", text: $weight)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad) // Allows decimal numbers
                            // Overlay to display "kg" text inside textfield on right
                            .overlay(Text("kg").padding(.trailing, 10), alignment: .trailing)
                            .foregroundColor(.white)
                            .accentColor(.green)

                        // Height input field - decimal pad keyboard with "cm" overlay
                        TextField("Height", text: $height)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad)
                            .overlay(Text("cm").padding(.trailing, 10), alignment: .trailing)
                            .foregroundColor(.white)
                            .accentColor(.green)
                    }

                    // Calculate button triggers BMI calculation when pressed
                    Button(action: calculateBMI) {
                        Text("Calculate")
                            .frame(maxWidth: .infinity)  // Make button full width
                            .padding()
                            // Button color orange if form valid, else gray
                            .background(isFormValid() ? Color.orange : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid()) // Disable button if inputs invalid
                }

                // Result display box for BMI category and value
                VStack(alignment: .leading, spacing: 10) {
                    Text("Result")
                        .foregroundColor(.white)
                        .fontWeight(.bold)

                    // Show bmiResult or default placeholder text if empty
                    Text(bmiResult.isEmpty ? "Weight Class: \nHealthy BMI range: \nHealthy weight for the height:" : bmiResult)
                        .foregroundColor(bmiResult.contains("⚠️") ? .red : .white) // Red text for warnings
                        .font(.body)
                        .padding(.top, 5)
                        .lineLimit(nil) // Allow multi-line text
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 180) // Bigger box to fit text
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)

                Spacer() // Push content up, fill remaining space
            }
            .padding() // Outer padding of entire VStack
        }
    }

    // MARK: - Helper method to check if form is valid for calculation
    func isFormValid() -> Bool {
        // Validate gender is selected, fields not empty, weight & height are valid numbers, height positive
        guard selectedGender != nil,
              !age.isEmpty,
              !weight.isEmpty,
              !height.isEmpty,
              let _ = Double(weight),
              let heightValue = Double(height),
              heightValue > 0 else {
            return false
        }
        return true
    }

    // MARK: - Calculate BMI and update result string & bmiValue for chart
    func calculateBMI() {
        // Check if gender selected, else set warning
        guard selectedGender != nil else {
            bmiResult = "⚠️ Please select your gender."
            return
        }

        // Check for empty fields and warn if any missing
        guard !age.isEmpty, !weight.isEmpty, !height.isEmpty else {
            bmiResult = "⚠️ Please fill in all the fields."
            return
        }

        // Convert weight and height strings to Double, validate positive height
        guard let weightValue = Double(weight),
              let heightValue = Double(height),
              heightValue > 0 else {
            bmiResult = "⚠️ Please enter valid numeric values."
            return
        }

        // Convert height from cm to meters for BMI calculation
        let heightInMeters = heightValue / 100
        // Calculate BMI formula: weight / (height^2)
        let bmi = weightValue / (heightInMeters * heightInMeters)
        bmiValue = bmi  // Store BMI value for chart and display

        // Determine BMI category based on ranges
        let category: String
        switch bmi {
        case ..<18.5: category = "Underweight"
        case 18.5..<25: category = "Normal weight"
        case 25..<30: category = "Overweight"
        default: category = "Obese"
        }

        // Format result string to show category and BMI value to 1 decimal place
        bmiResult = String(format: "Weight Class: %@\nYour BMI: %.1f", category, bmi)
    }
}

// MARK: - Separate view for displaying BMI categories in a bar chart
struct BMIChartView: View {
    let bmiValue: Double  // Input BMI value to highlight on chart
    
    var body: some View {
        // Define BMI range boundaries for categories
        let bmiRange: [Double] = [0, 18.5, 24.9, 29.9, 40]
        // Corresponding category labels
        let categories = ["Underweight", "Normal weight", "Overweight", "Obese"]
        
        return VStack {
            // Chart block using SwiftUI Charts framework
            Chart {
                // Iterate over each BMI category (except last upper bound)
                ForEach(0..<bmiRange.count-1, id: \.self) { i in
                    BarMark(
                        x: .value("Category", categories[i]),   // Category label on X axis
                        y: .value("BMI", bmiRange[i + 1])       // BMI upper bound on Y axis
                    )
                    // Highlight bar green if bmiValue falls within this range, else gray
                    .foregroundStyle(bmiValue >= bmiRange[i] && bmiValue < bmiRange[i + 1] ? Color.green : Color.gray.opacity(0.5))
                }
            }
            .frame(height: 150)  // Fixed height for chart
            .padding()

            // Show numeric BMI value below chart in white text
            Text(String(format: "BMI: %.1f", bmiValue))
                .foregroundColor(.white)
        }
    }
}

// Preview provider to enable live preview in Xcode canvas
#Preview {
    BMICalculatorView()
}

// MARK: - Extension to create Color from Hex string (optional utility)
extension Color {
    static func colorFromHex(_ hex: String) -> Color {
        // Remove non-alphanumeric characters from hex string
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        // Parse RGB components for standard 6-character hex code
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        } else {
            // Fallback to black if invalid hex
            r = 0; g = 0; b = 0
        }

        return Color(red: r, green: g, blue: b)
    }
}
