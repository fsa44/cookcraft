import SwiftUI
import Charts

struct BMICalculatorView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bmiResult: String = ""
    @State private var bmiValue: Double = 0
    @State private var selectedGender: Gender? = nil

    enum Gender {
        case male, female
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("BMI Calculator")
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()

                HStack(spacing: 30) {
                    Button(action: { selectedGender = .male }) {
                        VStack {
                            Image(systemName: "male")
                            Text("Male")
                        }
                        .padding()
                        .background(selectedGender == .male ? Color.green : Color.gray.opacity(0.6))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    }

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

                BMIChartView(bmiValue: bmiValue)  // Updated with dynamic chart
                    .frame(height: 200)

                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        TextField("Age", text: $age)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                            .accentColor(.green)

                        TextField("Weight", text: $weight)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad)
                            .overlay(Text("kg").padding(.trailing, 10), alignment: .trailing)
                            .foregroundColor(.white)
                            .accentColor(.green)

                        TextField("Height", text: $height)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad)
                            .overlay(Text("cm").padding(.trailing, 10), alignment: .trailing)
                            .foregroundColor(.white)
                            .accentColor(.green)
                    }

                    Button(action: calculateBMI) {
                        Text("Calculate")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid() ? Color.orange : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid())
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Result")
                        .foregroundColor(.white)
                        .fontWeight(.bold)

                    Text(bmiResult.isEmpty ? "Weight Class: \nHealthy BMI range: \nHealthy weight for the height:" : bmiResult)
                        .foregroundColor(bmiResult.contains("⚠️") ? .red : .white)
                        .font(.body)
                        .padding(.top, 5)
                        .lineLimit(nil)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 180)  // Increase minHeight for bigger box
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
    }

    func isFormValid() -> Bool {
        guard selectedGender != nil,
              !age.isEmpty,
              !weight.isEmpty,
              !height.isEmpty,
              var weightValue = Double(weight),
              let heightValue = Double(height),
              heightValue > 0 else {
            return false
        }
        return true
    }

    func calculateBMI() {
        guard selectedGender != nil else {
            bmiResult = "⚠️ Please select your gender."
            return
        }

        guard !age.isEmpty, !weight.isEmpty, !height.isEmpty else {
            bmiResult = "⚠️ Please fill in all the fields."
            return
        }

        guard let weightValue = Double(weight),
              let heightValue = Double(height),
              heightValue > 0 else {
            bmiResult = "⚠️ Please enter valid numeric values."
            return
        }

        let heightInMeters = heightValue / 100
        let bmi = weightValue / (heightInMeters * heightInMeters)
        bmiValue = bmi

        let category: String
        switch bmi {
        case ..<18.5: category = "Underweight"
        case 18.5..<25: category = "Normal weight"
        case 25..<30: category = "Overweight"
        default: category = "Obese"
        }

        bmiResult = String(format: "Weight Class: %@\nYour BMI: %.1f", category, bmi)
    }
}

struct BMIChartView: View {
    let bmiValue: Double
    
    var body: some View {
        let bmiRange: [Double] = [0, 18.5, 24.9, 29.9, 40]
        let categories = ["Underweight", "Normal weight", "Overweight", "Obese"]
        
        return VStack {
            Chart {
                ForEach(0..<bmiRange.count-1, id: \.self) { i in
                    BarMark(
                        x: .value("Category", categories[i]),
                        y: .value("BMI", bmiRange[i + 1])
                    )
                    .foregroundStyle(bmiValue >= bmiRange[i] && bmiValue < bmiRange[i + 1] ? Color.green : Color.gray.opacity(0.5))
                }
            }
            .frame(height: 150)
            .padding()

            Text(String(format: "BMI: %.1f", bmiValue))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    BMICalculatorView()
}



extension Color {
    static func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        } else {
            r = 0; g = 0; b = 0
        }

        return Color(red: r, green: g, blue: b)
    }
}
