import SwiftUI
import Charts

// MARK: - Main View for BMI Calculator
struct BMIView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bmiResult: String = ""
    @State private var bmiValue: Double = 0
    @State private var selectedGender: Gender? = nil
    @State private var selectedActivityLevel: ActivityLevel = .moderate // Default

    enum Gender { case male, female }
    enum ActivityLevel: Int, CaseIterable, Identifiable {
        case moderate = 1, Inactive = 2, active = 3
        var id: Int { rawValue }
        var label: String {
            switch self {
            case .Inactive: return "Inactive"
            case .moderate: return "Moderate"
            case .active: return "Active"
            }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#58B361"),
                    Color(hex: "#264D2A")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("")
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

                // Section Title for Activity Level
                Text("Activity Level")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
                
                // Activity Level Picker
                Picker("Activity Level", selection: $selectedActivityLevel) {
                    ForEach(ActivityLevel.allCases) { activity in
                        Text(activity.label).tag(activity)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 10)

                BMIChartView(bmiValue: bmiValue)
                    .frame(height: 200)

                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        TextField("", text: $age, prompt: Text("Age").foregroundStyle(.white.opacity(0.8)))
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                            .foregroundColor(.white)
                            .accentColor(.green)

                        TextField("", text: $weight, prompt:
                            Text("Weight").foregroundStyle(.white.opacity(0.8)))
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .keyboardType(.decimalPad)
                            .overlay(Text("kg").padding(.trailing, 10), alignment: .trailing)
                            .foregroundColor(.white)
                            .accentColor(.green)

                        TextField("", text: $height, prompt:
                            Text("Height").foregroundStyle(.white.opacity(0.8)))
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
                .frame(maxWidth: .infinity, minHeight: 180)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)

                Spacer()
            }
            .padding()
        }
    }

    // MARK: Validation
    func isFormValid() -> Bool {
        guard selectedGender != nil,
              !age.isEmpty,
              !weight.isEmpty,
              !height.isEmpty,
              let _ = Double(weight),
              let heightValue = Double(height),
              heightValue > 0,
              let ageValue = Int(age),
              ageValue > 0 else {
            return false
        }
        return true
    }

    // MARK: Calculate BMI and Classify
    func calculateBMI() {
        guard let gender = selectedGender,
              let ageVal = Int(age),
              ageVal > 0,
              let weightVal = Double(weight),
              let heightVal = Double(height),
              heightVal > 0 else {
            bmiResult = "⚠️ Please enter valid input values."
            return
        }
        let activityInt = selectedActivityLevel.rawValue
        let genderInt = (gender == .female) ? 0 : 1

        let heightMeters = heightVal / 100
        let bmi = weightVal / (heightMeters * heightMeters)
        bmiValue = bmi

        let category = classifyBMI(bmiValue: bmi, gender: genderInt, age: ageVal, activityLevel: activityInt)
        bmiResult = String(format: "Weight Class: %@\nYour BMI: %.1f", category, bmi)
    }

    // MARK: - Classification Algorithm
    func classifyBMI(bmiValue: Double, gender: Int, age: Int, activityLevel: Int) -> String {
        if bmiValue.isNaN { return "Unknown BMI" }

        let genderStr: String
        if gender == 0 {
            genderStr = "Female"
        } else if gender == 1 {
            genderStr = "Male"
        } else {
            return "Invalid Gender"
        }

        if age < 0 { return "Invalid Age" }

        let activityStr: String
        if activityLevel == 1 {
            activityStr = "Moderate"
        } else if activityLevel == 2 {
            activityStr = "Inactive"
        } else if activityLevel == 3 {
            activityStr = "Active"
        } else {
            activityStr = "Unknown"
        }

        var thresholds: [String: Double]
        if genderStr == "Female" {
            thresholds = [
                "Underweight": 18.5,
                "Normal": 26,
                "Overweight": 31
            ]
        } else {
            thresholds = [
                "Underweight": 18.5,
                "Normal": 25,
                "Overweight": 30
            ]
        }

        if activityStr == "Inactive" {
            thresholds["Normal"]! -= 1
            thresholds["Overweight"]! -= 1
        } else if activityStr == "Active" {
            thresholds["Normal"]! += 1
            thresholds["Overweight"]! += 1
        }

        if age >= 60 {
            thresholds["Underweight"] = 22
            thresholds["Normal"] = 27
            thresholds["Overweight"] = 32
        } else if age < 18 {
            thresholds["Underweight"] = 18.0
            thresholds["Normal"] = 23
            thresholds["Overweight"] = 28
        }

        if bmiValue < thresholds["Underweight"]! {
            return "Underweight"
        } else if bmiValue < thresholds["Normal"]! {
            return "Normal"
        } else if bmiValue < thresholds["Overweight"]! {
            return "Overweight"
        } else {
            return "Obese"
        }
    }
}

// MARK: - Bar Chart for BMI categories
struct BMIChartView: View {
    let bmiValue: Double
    var body: some View {
        let bmiRange: [Double] = [0, 18.5, 24.9, 29.9, 40]
        let categories = ["Underweight", "Normal weight", "Overweight", "Obese"]
        VStack {
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

// MARK: - Preview
#Preview {
    BMIView()
}
