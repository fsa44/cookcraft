//import SwiftUI
//import Charts
//
//// MARK: - Main View for BMI Calculator
//struct BMIView: View {
//    @State private var age: String = ""
//    @State private var weight: String = ""
//    @State private var height: String = ""
//    @State private var bmiResult: String = ""
//    @State private var bmiValue: Double = 0
//    @State private var selectedGender: Gender? = nil
//    @State private var selectedActivityLevel: ActivityLevel = .moderate // Default
//
//    enum Gender { case male, female }
//    enum ActivityLevel: Int, CaseIterable, Identifiable {
//        case moderate = 1, Inactive = 2, active = 3
//        var id: Int { rawValue }
//        var label: String {
//            switch self {
//            case .Inactive: return "Inactive"
//            case .moderate: return "Moderate"
//            case .active: return "Active"
//            }
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(hex: "#58B361"),
//                    Color(hex: "#264D2A")
//                ]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 20) {
//                Text("BMI Calculator")
//                    .font(.title)
//                    .foregroundColor(.white)
//                    .bold()
//
//                HStack(spacing: 30) {
//                    Button(action: { selectedGender = .male }) {
//                        VStack {
//                            Image(systemName: "male")
//                            Text("Male")
//                        }
//                        .padding()
//                        .background(selectedGender == .male ? Color.green : Color.gray.opacity(0.6))
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                    }
//                    Button(action: { selectedGender = .female }) {
//                        VStack {
//                            Image(systemName: "female")
//                            Text("Female")
//                        }
//                        .padding()
//                        .background(selectedGender == .female ? Color.green : Color.gray.opacity(0.6))
//                        .cornerRadius(10)
//                        .foregroundColor(.white)
//                    }
//                }
//
//                // Section Title for Activity Level
//                Text("Activity Level")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading, 4)
//
//                // Activity Level Picker
//                Picker("Activity Level", selection: $selectedActivityLevel) {
//                    ForEach(ActivityLevel.allCases) { activity in
//                        Text(activity.label).tag(activity)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.bottom, 10)
//
//                BMIChartView(bmiValue: bmiValue)
//                    .frame(height: 200)
//
//                VStack(spacing: 15) {
//                    HStack(spacing: 15) {
//                        TextField("", text: $age, prompt: Text("Age").foregroundStyle(.white.opacity(0.8)))
//                            .padding()
//                            .background(Color.white.opacity(0.2))
//                            .cornerRadius(10)
//                            .keyboardType(.numberPad)
//                            .foregroundColor(.white)
//                            .accentColor(.green)
//
//                        TextField("", text: $weight, prompt:
//                            Text("Weight").foregroundStyle(.white.opacity(0.8)))
//                            .padding()
//                            .background(Color.white.opacity(0.2))
//                            .cornerRadius(10)
//                            .keyboardType(.decimalPad)
//                            .overlay(Text("kg").padding(.trailing, 10), alignment: .trailing)
//                            .foregroundColor(.white)
//                            .accentColor(.green)
//
//                        TextField("", text: $height, prompt:
//                            Text("Height").foregroundStyle(.white.opacity(0.8)))
//                            .padding()
//                            .background(Color.white.opacity(0.2))
//                            .cornerRadius(10)
//                            .keyboardType(.decimalPad)
//                            .overlay(Text("cm").padding(.trailing, 10), alignment: .trailing)
//                            .foregroundColor(.white)
//                            .accentColor(.green)
//                    }
//
//                    Button(action: calculateBMI) {
//                        Text("Calculate")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(isFormValid() ? Color.orange : Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .disabled(!isFormValid())
//                }
//
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Result")
//                        .foregroundColor(.white)
//                        .fontWeight(.bold)
//                    Text(bmiResult.isEmpty ? "Weight Class: \nHealthy BMI range: \nHealthy weight for the height:" : bmiResult)
//                        .foregroundColor(bmiResult.contains("⚠️") ? .red : .white)
//                        .font(.body)
//                        .padding(.top, 5)
//                        .lineLimit(nil)
//                }
//                .padding()
//                .frame(maxWidth: .infinity, minHeight: 180)
//                .background(Color.white.opacity(0.2))
//                .cornerRadius(10)
//
//                Spacer()
//            }
//            .padding()
//        }
//    }
//
//    // MARK: Validation
//    func isFormValid() -> Bool {
//        guard selectedGender != nil,
//              !age.isEmpty,
//              !weight.isEmpty,
//              !height.isEmpty,
//              let _ = Double(weight),
//              let heightValue = Double(height),
//              heightValue > 0,
//              let ageValue = Int(age),
//              ageValue > 0 else {
//            return false
//        }
//        return true
//    }
//
//    // MARK: Calculate BMI and Classify
//    func calculateBMI() {
//        guard let gender = selectedGender,
//              let ageVal = Int(age),
//              ageVal > 0,
//              let weightVal = Double(weight),
//              let heightVal = Double(height),
//              heightVal > 0 else {
//            bmiResult = "⚠️ Please enter valid input values."
//            return
//        }
//        let activityInt = selectedActivityLevel.rawValue
//        let genderInt = (gender == .female) ? 0 : 1
//
//        let heightMeters = heightVal / 100
//        let bmi = weightVal / (heightMeters * heightMeters)
//        bmiValue = bmi
//
//        let category = classifyBMI(bmiValue: bmi, gender: genderInt, age: ageVal, activityLevel: activityInt)
//        bmiResult = String(format: "Weight Class: %@\nYour BMI: %.1f", category, bmi)
//    }
//
//    // MARK: - Classification Algorithm
//    func classifyBMI(bmiValue: Double, gender: Int, age: Int, activityLevel: Int) -> String {
//        if bmiValue.isNaN { return "Unknown BMI" }
//
//        let genderStr: String
//        if gender == 0 {
//            genderStr = "Female"
//        } else if gender == 1 {
//            genderStr = "Male"
//        } else {
//            return "Invalid Gender"
//        }
//
//        if age < 0 { return "Invalid Age" }
//
//        let activityStr: String
//        if activityLevel == 1 {
//            activityStr = "Moderate"
//        } else if activityLevel == 2 {
//            activityStr = "Inactive"
//        } else if activityLevel == 3 {
//            activityStr = "Active"
//        } else {
//            activityStr = "Unknown"
//        }
//
//        var thresholds: [String: Double]
//        if genderStr == "Female" {
//            thresholds = [
//                "Underweight": 18.5,
//                "Normal": 26,
//                "Overweight": 31
//            ]
//        } else {
//            thresholds = [
//                "Underweight": 18.5,
//                "Normal": 25,
//                "Overweight": 30
//            ]
//        }
//
//        if activityStr == "Inactive" {
//            thresholds["Normal"]! -= 1
//            thresholds["Overweight"]! -= 1
//        } else if activityStr == "Active" {
//            thresholds["Normal"]! += 1
//            thresholds["Overweight"]! += 1
//        }
//
//        if age >= 60 {
//            thresholds["Underweight"] = 22
//            thresholds["Normal"] = 27
//            thresholds["Overweight"] = 32
//        } else if age < 18 {
//            thresholds["Underweight"] = 18.0
//            thresholds["Normal"] = 23
//            thresholds["Overweight"] = 28
//        }
//
//        if bmiValue < thresholds["Underweight"]! {
//            return "Underweight"
//        } else if bmiValue < thresholds["Normal"]! {
//            return "Normal"
//        } else if bmiValue < thresholds["Overweight"]! {
//            return "Overweight"
//        } else {
//            return "Obese"
//        }
//    }
//}
//
//// MARK: - Bar Chart for BMI categories
//struct BMIChartView: View {
//    let bmiValue: Double
//    var body: some View {
//        let bmiRange: [Double] = [0, 18.5, 24.9, 29.9, 40]
//        let categories = ["Underweight", "Normal weight", "Overweight", "Obese"]
//        VStack {
//            Chart {
//                ForEach(0..<bmiRange.count-1, id: \.self) { i in
//                    BarMark(
//                        x: .value("Category", categories[i]),
//                        y: .value("BMI", bmiRange[i + 1])
//                    )
//                    .foregroundStyle(bmiValue >= bmiRange[i] && bmiValue < bmiRange[i + 1] ? Color.green : Color.gray.opacity(0.5))
//                }
//            }
//            .frame(height: 150)
//            .padding()
//            Text(String(format: "BMI: %.1f", bmiValue))
//                .foregroundColor(.white)
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    BMIView()
//}



//import SwiftUI
//
//// MARK: - Unit System Enum
//enum UnitSystem: String, CaseIterable, Identifiable {
//    case metric = "Metric (kg/cm)"
//    case imperial = "Imperial (lb/in)"
//
//    var id: String { self.rawValue }
//}
//
//// MARK: - Gender & ActivityLevel Enums
//enum Gender: String, CaseIterable, Identifiable {
//    case male = "Male"
//    case female = "Female"
//
//    var id: String { rawValue }
//}
//
//enum ActivityLevel: Int, CaseIterable, Identifiable {
//    case inactive = 1, moderate = 2, active = 3
//    var id: Int { rawValue }
//    var label: String {
//        switch self {
//        case .inactive: return "Inactive"
//        case .moderate: return "Moderate"
//        case .active: return "Active"
//        }
//    }
//}
//
//// MARK: - Main BMI View
//struct BMIView: View {
//    @State private var unitSystem: UnitSystem = .metric
//    @State private var selectedGender: Gender? = nil
//    @State private var selectedActivityLevel: ActivityLevel = .moderate
//    @State private var age: String = ""
//    @State private var weight: String = ""
//    @State private var height: String = ""
//    @State private var bmi: Double = 0
//    @State private var showResult = false
//
//    // MARK: - Conversion
//    var convertedWeight: Double {
//        guard let w = Double(weight) else { return 0 }
//        return unitSystem == .metric ? w : w * 0.453592
//    }
//
//    var convertedHeight: Double {
//        guard let h = Double(height) else { return 0 }
//        return unitSystem == .metric ? h / 100 : h * 0.0254
//    }
//
//    var calculatedBMI: Double {
//        let h = convertedHeight
//        guard h > 0 else { return 0 }
//        return convertedWeight / (h * h)
//    }
//
//    var category: String {
//        switch bmi {
//        case ..<18.5: return "Underweight"
//        case 18.5..<25: return "Normal"
//        case 25..<30: return "Overweight"
//        default: return "Obese"
//        }
//    }
//
//    var categoryColor: Color {
//        switch bmi {
//        case ..<18.5: return .blue
//        case 18.5..<25: return .green
//        case 25..<30: return .orange
//        default: return .red
//        }
//    }
//
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 25) {
//
//                    // MARK: - Gender + Unit Selection Row
//                    HStack(alignment: .top, spacing: 25) {
//                        // Gender Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Gender")
//                                .font(.headline)
//                                .foregroundColor(.white)
//
//                            HStack(spacing: 20) {
//                                ForEach(Gender.allCases) { gender in
//                                    Button(action: { selectedGender = gender }) {
//                                        VStack(spacing: 8) {
//                                            Image(systemName: gender == .male ? "person" : "person.fill")
//                                                .font(.title2)
//                                            Text(gender.rawValue)
//                                                .font(.caption)
//                                        }
//                                        .padding()
//                                        .frame(width: 80, height: 80)
//                                        .background(selectedGender == gender ? Color.green : Color.gray.opacity(0.4))
//                                        .cornerRadius(12)
//                                        .foregroundColor(.white)
//                                    }
//                                }
//                            }
//                        }
//
//                        // Unit System Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Unit System")
//                                .font(.headline)
//                                .foregroundColor(.white)
//
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(UnitSystem.allCases) { unit in
//                                    Button(action: { unitSystem = unit }) {
//                                        HStack {
//                                            Image(systemName: unitSystem == unit ? "checkmark.circle.fill" : "circle")
//                                            Text(unit.rawValue)
//                                        }
//                                        .foregroundColor(.white)
//                                    }
//                                }
//                            }
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 10)
//                            .background(Color.white.opacity(0.1))
//                            .cornerRadius(12)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 45)
//
//                    // MARK: - Activity Level Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Activity Level")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding(.leading, 16)
//                            .padding(.top, 10)
//
//                        Divider()
//                            .background(Color.white.opacity(0.5))
//
//                        Picker("Activity Level", selection: $selectedActivityLevel) {
//                            ForEach(ActivityLevel.allCases) { activity in
//                                Text(activity.label).tag(activity)
//                            }
//                        }
//                        .pickerStyle(.segmented)
//                        .padding(.horizontal)
//                        .padding(.top, 5)
//                    }
//
//                    // MARK: - Input Fields (replicated style from first version)
//                    VStack(spacing: 15) {
//                        HStack(spacing: 15) {
//                            TextField("", text: $age, prompt: Text("Age").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.numberPad)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//
//                            TextField("", text: $weight, prompt:
//                                Text(unitSystem == .metric ? "Weight" : "Weight").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.decimalPad)
//                                .overlay(Text(unitSystem == .metric ? "kg" : "lb")
//                                            .padding(.trailing, 10), alignment: .trailing)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//
//                            TextField("", text: $height, prompt:
//                                Text(unitSystem == .metric ? "Height" : "Height").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.decimalPad)
//                                .overlay(Text(unitSystem == .metric ? "cm" : "in")
//                                            .padding(.trailing, 10), alignment: .trailing)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//                        }
//                    }
//                    .padding(.horizontal)
//
//                    // MARK: - Calculate Button
//                    Button(action: {
//                        withAnimation(.easeInOut(duration: 1.0)) {
//                            bmi = calculatedBMI
//                            showResult = true
//                        }
//                    }) {
//                        Text("Calculate BMI")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background((selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty) ? Color.gray : Color.orange)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .disabled(selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty)
//                    .padding(.horizontal)
//
//                    // MARK: - BMI Results
//                    if showResult {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 24, style: .continuous)
//                                .fill(Color.white.opacity(0.2))
//                                .frame(maxWidth: 350, minHeight: 150, maxHeight: 350)
//                                .padding(.horizontal, 6)
//
//                            VStack(spacing: 12) {
//                                Text(String(format: "BMI: %.2f", bmi))
//                                    .font(.title)
//                                    .bold()
//                                    .foregroundColor(categoryColor)
//
//                                Text(category)
//                                    .font(.headline)
//                                    .foregroundColor(categoryColor)
//
//                                SemiCircleChart(bmi: bmi)
//                                    .frame(height: 220)
//                                    .padding(.top, 10)
//                            }
//                            .padding(.bottom, -45)
//                        }
//                        .transition(.opacity.combined(with: .scale))
//                    }
//                }
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Text("BMI Calculator")
//                            .font(.system(size: 30, weight: .bold))
//                            .foregroundColor(.white)
//                            .padding(.top, 40)
//                            .padding(.trailing, 160)
//                    }
//                }
//                .foregroundColor(.white)
//            }
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(hex: "#58B361"),
//                        Color(hex: "#264D2A")
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//            )
//        }
//        .background(Color.clear)
//    }
//}
//
//// MARK: - Supporting Views for Gauge
//struct SemiCircleChart: View {
//    let bmi: Double
//    @State private var progress: Double = 0
//    let tickValues: [Double] = [10, 18.5, 25, 30, 40]
//    let tickLabels: [Double: String] = [
//        10: "Low", 18.5: "Under", 25: "Normal", 30: "Over", 40: "Obese"
//    ]
//
//    var needleAngle: Angle {
//        let clampedBMI = min(max(bmi, 10), 40)
//        let percentage = (clampedBMI - 10) / 30
//        return .degrees(percentage * 180)
//    }
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .trim(from: 0.0, to: 0.5)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 30)
//                .rotationEffect(.degrees(180))
//
//            Circle()
//                .trim(from: 0.0, to: min(CGFloat(progress / 40), 0.5))
//                .stroke(AngularGradient(
//                    gradient: Gradient(colors: [.blue, .green, .orange, .red]),
//                    center: .center
//                ), style: StrokeStyle(lineWidth: 30, lineCap: .round))
//                .rotationEffect(.degrees(180))
//                .animation(.easeOut(duration: 1.0), value: progress)
//
//            NeedleIndicator(angle: needleAngle)
//                .stroke(Color.black, lineWidth: 3)
//                .frame(width: 160, height: 160)
//                .animation(.easeInOut(duration: 1.0), value: needleAngle)
//
//            VStack {
//                Text("BMI Gauge")
//                    .font(.caption)
//                Text(String(format: "%.1f", bmi))
//                    .font(.system(size: 36, weight: .bold))
//            }
//            .offset(y: 20)
//        }
//        .frame(height: 220)
//        .onAppear { progress = bmi }
//        .onChange(of: bmi) { newValue in progress = newValue }
//    }
//}
//
//struct NeedleIndicator: Shape {
//    var angle: Angle
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let radius = min(rect.width, rect.height) / 2
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let endX = center.x + radius * cos(CGFloat(angle.radians - .pi))
//        let endY = center.y + radius * sin(CGFloat(angle.radians - .pi))
//        path.move(to: center)
//        path.addLine(to: CGPoint(x: endX, y: endY))
//        return path
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    BMIView()
//        .environmentObject(SupabaseAuthService()) // Inject the environment object
//        .onAppear {
//        }
//}


//import SwiftUI
//
//// MARK: - Unit System Enum
//enum UnitSystem: String, CaseIterable, Identifiable {
//    case metric = "Metric (kg/cm)"
//    case imperial = "Imperial (lb/in)"
//
//    var id: String { self.rawValue }
//}
//
//// MARK: - Gender & ActivityLevel Enums
//enum Gender: String, CaseIterable, Identifiable {
//    case male = "Male"
//    case female = "Female"
//
//    var id: String { rawValue }
//}
//
//enum ActivityLevel: Int, CaseIterable, Identifiable {
//    case inactive = 1, moderate = 2, active = 3
//    var id: Int { rawValue }
//    var label: String {
//        switch self {
//        case .inactive: return "Inactive"
//        case .moderate: return "Moderate"
//        case .active: return "Active"
//        }
//    }
//}
//
//// MARK: - Main BMI View
//struct BMIView: View {
//    @State private var unitSystem: UnitSystem = .metric
//    @State private var selectedGender: Gender? = nil
//    @State private var selectedActivityLevel: ActivityLevel = .moderate
//    @State private var age: String = ""
//    @State private var weight: String = ""
//    @State private var height: String = ""
//    @State private var bmi: Double = 0
//    @State private var showResult = false
//
//    // MARK: - Conversion
//    var convertedWeight: Double {
//        guard let w = Double(weight) else { return 0 }
//        return unitSystem == .metric ? w : w * 0.453592
//    }
//
//    var convertedHeight: Double {
//        guard let h = Double(height) else { return 0 }
//        return unitSystem == .metric ? h / 100 : h * 0.0254
//    }
//
//    var calculatedBMI: Double {
//        let h = convertedHeight
//        guard h > 0 else { return 0 }
//        return convertedWeight / (h * h)
//    }
//
//    // MARK: - Adaptive Classification Logic
//    func classifyBMI(bmiValue: Double, gender: Gender?, age: Int, activityLevel: ActivityLevel) -> String {
//        guard !bmiValue.isNaN else { return "Unknown BMI" }
//        guard let gender = gender else { return "Invalid Gender" }
//        guard age >= 0 else { return "Invalid Age" }
//
//        let genderStr = gender == .female ? "Female" : "Male"
//        var activityStr: String
//        switch activityLevel {
//        case .inactive:
//            activityStr = "Inactive"
//        case .moderate:
//            activityStr = "Moderate"
//        case .active:
//            activityStr = "Active"
//        }
//
//        // Base thresholds
//        var thresholds: [String: Double]
//        if genderStr == "Female" {
//            thresholds = [
//                "Underweight": 18.5,
//                "Normal": 26,
//                "Overweight": 31
//            ]
//        } else { // Male
//            thresholds = [
//                "Underweight": 18.5,
//                "Normal": 25,
//                "Overweight": 30
//            ]
//        }
//
//        // Adjust thresholds by activity level
//        if activityStr == "Inactive" {
//            thresholds["Normal"]! -= 1
//            thresholds["Overweight"]! -= 1
//        } else if activityStr == "Active" {
//            thresholds["Normal"]! += 1
//            thresholds["Overweight"]! += 1
//        }
//
//        // Adjust thresholds by age
//        if age >= 60 {
//            thresholds["Underweight"] = 22
//            thresholds["Normal"] = 27
//            thresholds["Overweight"] = 32
//        } else if age < 18 {
//            thresholds["Underweight"] = 18.0
//            thresholds["Normal"] = 23
//            thresholds["Overweight"] = 28
//        }
//
//        // Final classification
//        if bmiValue < thresholds["Underweight"]! {
//            return "Underweight"
//        } else if bmiValue < thresholds["Normal"]! {
//            return "Normal"
//        } else if bmiValue < thresholds["Overweight"]! {
//            return "Overweight"
//        } else {
//            return "Obese"
//        }
//    }
//
//    // MARK: - Category Label & Color
//    var category: String {
//        let ageInt = Int(age) ?? -1
//        return classifyBMI(
//            bmiValue: bmi,
//            gender: selectedGender,
//            age: ageInt,
//            activityLevel: selectedActivityLevel
//        )
//    }
//
//    var categoryColor: Color {
//        switch category {
//        case "Underweight": return .blue
//        case "Normal": return .green
//        case "Overweight": return .orange
//        case "Obese": return .red
//        default: return .gray
//        }
//    }
//
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 25) {
//
//                    // MARK: - Gender + Unit Selection Row
//                    HStack(alignment: .top, spacing: 25) {
//                        // Gender Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Gender")
//                                .font(.headline)
//                                .foregroundColor(.white)
//
//                            HStack(spacing: 20) {
//                                ForEach(Gender.allCases) { gender in
//                                    Button(action: { selectedGender = gender }) {
//                                        VStack(spacing: 8) {
//                                            Image(systemName: gender == .male ? "person" : "person.fill")
//                                                .font(.title2)
//                                            Text(gender.rawValue)
//                                                .font(.caption)
//                                        }
//                                        .padding()
//                                        .frame(width: 80, height: 80)
//                                        .background(selectedGender == gender ? Color.green : Color.gray.opacity(0.4))
//                                        .cornerRadius(12)
//                                        .foregroundColor(.white)
//                                    }
//                                }
//                            }
//                        }
//
//                        // Unit System Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Unit System")
//                                .font(.headline)
//                                .foregroundColor(.white)
//
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(UnitSystem.allCases) { unit in
//                                    Button(action: { unitSystem = unit }) {
//                                        HStack {
//                                            Image(systemName: unitSystem == unit ? "checkmark.circle.fill" : "circle")
//                                            Text(unit.rawValue)
//                                        }
//                                        .foregroundColor(.white)
//                                    }
//                                }
//                            }
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 10)
//                            .background(Color.white.opacity(0.1))
//                            .cornerRadius(12)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 45)
//
//                    // MARK: - Activity Level Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Activity Level")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding(.leading, 16)
//                            .padding(.top, 10)
//
//                        Divider()
//                            .background(Color.white.opacity(0.5))
//
//                        Picker("Activity Level", selection: $selectedActivityLevel) {
//                            ForEach(ActivityLevel.allCases) { activity in
//                                Text(activity.label).tag(activity)
//                            }
//                        }
//                        .pickerStyle(.segmented)
//                        .padding(.horizontal)
//                        .padding(.top, 5)
//                    }
//
//                    // MARK: - Input Fields
//                    VStack(spacing: 15) {
//                        HStack(spacing: 15) {
//                            TextField("", text: $age, prompt: Text("Age").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.numberPad)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//
//                            TextField("", text: $weight, prompt: Text(unitSystem == .metric ? "Weight" : "Weight").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.decimalPad)
//                                .overlay(Text(unitSystem == .metric ? "kg" : "lb").padding(.trailing, 10), alignment: .trailing)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//
//                            TextField("", text: $height, prompt: Text(unitSystem == .metric ? "Height" : "Height").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.decimalPad)
//                                .overlay(Text(unitSystem == .metric ? "cm" : "in").padding(.trailing, 10), alignment: .trailing)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//                        }
//                    }
//                    .padding(.horizontal)
//
//                    // MARK: - Calculate Button
//                    Button(action: {
//                        withAnimation(.easeInOut(duration: 1.0)) {
//                            bmi = calculatedBMI
//                            showResult = true
//                        }
//                    }) {
//                        Text("Calculate BMI")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background((selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty) ? Color.gray : Color.orange)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    .disabled(selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty)
//                    .padding(.horizontal)
//
//                    // MARK: - BMI Results
//                    if showResult {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 24, style: .continuous)
//                                .fill(Color.white.opacity(0.2))
//                                .frame(maxWidth: 350, minHeight: 150, maxHeight: 350)
//                                .padding(.horizontal, 6)
//
//                            VStack(spacing: 12) {
//                                Text(String(format: "BMI: %.2f", bmi))
//                                    .font(.title)
//                                    .bold()
//                                    .foregroundColor(categoryColor)
//
//                                Text(category)
//                                    .font(.headline)
//                                    .foregroundColor(categoryColor)
//
//                                SemiCircleChart(bmi: bmi)
//                                    .frame(height: 220)
//                                    .padding(.top, 10)
//                            }
//                            .padding(.bottom, -45)
//                        }
//                        .transition(.opacity.combined(with: .scale))
//                    }
//                }
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        Text("BMI Calculator")
//                            .font(.system(size: 30, weight: .bold))
//                            .foregroundColor(.white)
//                            .padding(.top, 40)
//                            .padding(.trailing, 160)
//                    }
//                }
//                .foregroundColor(.white)
//            }
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(hex: "#58B361"),
//                        Color(hex: "#264D2A")
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//            )
//        }
//        .background(Color.clear)
//    }
//}
//
//// MARK: - Supporting Views for Gauge
//struct SemiCircleChart: View {
//    let bmi: Double
//    @State private var progress: Double = 0
//    let tickValues: [Double] = [10, 18.5, 25, 30, 40]
//    let tickLabels: [Double: String] = [
//        10: "Low", 18.5: "Under", 25: "Normal", 30: "Over", 40: "Obese"
//    ]
//
//    var needleAngle: Angle {
//        let clampedBMI = min(max(bmi, 10), 40)
//        let percentage = (clampedBMI - 10) / 30
//        return .degrees(percentage * 180)
//    }
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .trim(from: 0.0, to: 0.5)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 30)
//                .rotationEffect(.degrees(180))
//
//            Circle()
//                .trim(from: 0.0, to: min(CGFloat(progress / 40), 0.5))
//                .stroke(AngularGradient(
//                    gradient: Gradient(colors: [.blue, .green, .orange, .red]),
//                    center: .center
//                ), style: StrokeStyle(lineWidth: 30, lineCap: .round))
//                .rotationEffect(.degrees(180))
//                .animation(.easeOut(duration: 1.0), value: progress)
//
//            NeedleIndicator(angle: needleAngle)
//                .stroke(Color.black, lineWidth: 3)
//                .frame(width: 160, height: 160)
//                .animation(.easeInOut(duration: 1.0), value: needleAngle)
//
//            VStack {
//                Text("BMI Gauge")
//                    .font(.caption)
//                Text(String(format: "%.1f", bmi))
//                    .font(.system(size: 36, weight: .bold))
//            }
//            .offset(y: 20)
//        }
//        .frame(height: 220)
//        .onAppear { progress = bmi }
//        .onChange(of: bmi) { newValue in progress = newValue }
//    }
//}
//
//struct NeedleIndicator: Shape {
//    var angle: Angle
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let radius = min(rect.width, rect.height) / 2
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let endX = center.x + radius * cos(CGFloat(angle.radians - .pi))
//        let endY = center.y + radius * sin(CGFloat(angle.radians - .pi))
//        path.move(to: center)
//        path.addLine(to: CGPoint(x: endX, y: endY))
//        return path
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    BMIView()
//        .environmentObject(SupabaseAuthService())
//}


//import SwiftUI
//
//// MARK: - Unit System Enum
//enum UnitSystem: String, CaseIterable, Identifiable {
//    case metric = "Metric (kg/cm)"
//    case imperial = "Imperial (lb/in)"
//    var id: String { self.rawValue }
//}
//
//// MARK: - Gender & ActivityLevel Enums
//enum Gender: String, CaseIterable, Identifiable {
//    case male = "Male"
//    case female = "Female"
//    var id: String { rawValue }
//}
//
//enum ActivityLevel: Int, CaseIterable, Identifiable {
//    case inactive = 1, moderate = 2, active = 3
//    var id: Int { rawValue }
//    var label: String {
//        switch self {
//        case .inactive: return "Inactive"
//        case .moderate: return "Moderate"
//        case .active: return "Active"
//        }
//    }
//}
//
//// MARK: - BMIResult Data Model
//struct BMIResult: Identifiable {
//    let id = UUID() // sheet(item:) requires identifiable
//    let timestamp: Date
//    let bmi: Double
//    let category: String
//    let gender: Gender?
//    let age: String
//    let activityLevel: ActivityLevel
//    let heightInMeters: Double
//}
//
//
//// MARK: - Main BMI View
//struct BMIView: View {
//    @EnvironmentObject var authService: SupabaseAuthService
//
//    @State private var unitSystem: UnitSystem = .metric
//    @State private var selectedGender: Gender? = nil
//    @State private var selectedActivityLevel: ActivityLevel = .moderate
//    @State private var age: String = ""
//    @State private var weight: String = ""
//    @State private var height: String = ""
//    @State private var bmi: Double = 0
//    @State private var showResult = false
//    @State private var animateGradient = false
//    
//    // BMI Results Modal
//    @State private var showResultsSheet = false
//    
//    
//    // MARK: - Conversion
//    var convertedWeight: Double {
//        guard let w = Double(weight) else { return 0 }
//        return unitSystem == .metric ? w : w * 0.453592
//    }
//    
//    var convertedHeight: Double {
//        guard let h = Double(height) else { return 0 }
//        return unitSystem == .metric ? h / 100 : h * 0.0254
//    }
//    
//    var calculatedBMI: Double {
//        let h = convertedHeight
//        guard h > 0 else { return 0 }
//        return convertedWeight / (h * h)
//    }
//    
//    // MARK: - Adaptive BMI Classification
//    func classifyBMI(bmiValue: Double, gender: Gender?, age: Int, activityLevel: ActivityLevel) -> String {
//        guard !bmiValue.isNaN else { return "Unknown BMI" }
//        guard let gender = gender else { return "Invalid Gender" }
//        guard age >= 0 else { return "Invalid Age" }
//        
//        let genderStr = gender == .female ? "Female" : "Male"
//        var activityStr: String
//        switch activityLevel {
//        case .inactive: activityStr = "Inactive"
//        case .moderate: activityStr = "Moderate"
//        case .active: activityStr = "Active"
//        }
//        
//        // Base thresholds
//        var thresholds: [String: Double] = [:]
//        if genderStr == "Female" {
//            thresholds = [
//                "Underweight": 18.5,
//                "Normal": 26,
//                "Overweight": 31
//            ]
//        } else {
//            thresholds = [
//                "Underweight": 18.5,
//                "Normal": 25,
//                "Overweight": 30
//            ]
//        }
//        
//        // Modify thresholds by activity level
//        if activityStr == "Inactive" {
//            thresholds["Normal"]! -= 1
//            thresholds["Overweight"]! -= 1
//        } else if activityStr == "Active" {
//            thresholds["Normal"]! += 1
//            thresholds["Overweight"]! += 1
//        }
//        
//        // Modify thresholds by age
//        if age >= 60 {
//            thresholds["Underweight"] = 22
//            thresholds["Normal"] = 27
//            thresholds["Overweight"] = 32
//        } else if age < 18 {
//            thresholds["Underweight"] = 18.0
//            thresholds["Normal"] = 23
//            thresholds["Overweight"] = 28
//        }
//        
//        // Final classification
//        if bmiValue < thresholds["Underweight"]! {
//            return "Underweight"
//        } else if bmiValue < thresholds["Normal"]! {
//            return "Normal"
//        } else if bmiValue < thresholds["Overweight"]! {
//            return "Overweight"
//        } else {
//            return "Obese"
//        }
//    }
//    
//    // MARK: - Dynamic Category & Colors
//    var category: String {
//        let ageInt = Int(age) ?? -1
//        return classifyBMI(
//            bmiValue: bmi,
//            gender: selectedGender,
//            age: ageInt,
//            activityLevel: selectedActivityLevel
//        )
//    }
//    
//    var categoryColor: Color {
//        switch category {
//        case "Underweight": return .blue
//        case "Normal": return .green
//        case "Overweight": return .orange
//        case "Obese": return .red
//        default: return .gray
//        }
//    }
//    
//    var gradientColors: [Color] {
//        switch category {
//        case "Underweight": return [Color.blue, Color.cyan]
//        case "Normal": return [Color.green, Color.teal]
//        case "Overweight": return [Color.orange, Color.yellow]
//        case "Obese": return [Color.red, Color.pink]
//        default: return [Color.gray, Color.gray.opacity(0.5)]
//        }
//    }
//    
//    // MARK: - Reset/clear function
//    func resetFields() {
//        selectedGender = nil
//        selectedActivityLevel = .moderate
//        age = ""
//        weight = ""
//        height = ""
//        bmi = 0
//        showResult = false
//        animateGradient = false
//    }
//    
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 25) {
//                    // Title
//                    Text("BMI Calculator")
//                        .font(.system(size: 30, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding(.top, 32)
//                        .padding(.trailing, 160)
//                    
//                    // Gender + Unit Row
//                    HStack(alignment: .top, spacing: 25) {
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Gender")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                            HStack(spacing: 20) {
//                                ForEach(Gender.allCases) { gender in
//                                    Button(action: { selectedGender = gender }) {
//                                        VStack(spacing: 8) {
//                                            Image(systemName: gender == .male ? "person" : "person.fill")
//                                                .font(.title2)
//                                            Text(gender.rawValue)
//                                                .font(.caption)
//                                        }
//                                        .padding()
//                                        .frame(width: 80, height: 80)
//                                        .background(selectedGender == gender ? Color.green : Color.gray.opacity(0.4))
//                                        .cornerRadius(12)
//                                        .foregroundColor(.white)
//                                    }
//                                }
//                            }
//                        }
//                        
//                        // Unit System Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("Unit System")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                            VStack(alignment: .leading, spacing: 10) {
//                                ForEach(UnitSystem.allCases) { unit in
//                                    Button(action: { unitSystem = unit }) {
//                                        HStack {
//                                            Image(systemName: unitSystem == unit ? "checkmark.circle.fill" : "circle")
//                                            Text(unit.rawValue)
//                                        }
//                                        .foregroundColor(.white)
//                                    }
//                                }
//                            }
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 10)
//                            .background(Color.white.opacity(0.1))
//                            .cornerRadius(12)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 5)
//                    
//                    // Activity Level Section
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("Activity Level")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding(.leading, 16)
//                            .padding(.top, 10)
//                        
//                        Divider().background(Color.white.opacity(0.5))
//                        
//                        Picker("Activity Level", selection: $selectedActivityLevel) {
//                            ForEach(ActivityLevel.allCases) { activity in
//                                Text(activity.label).tag(activity)
//                            }
//                        }
//                        .pickerStyle(.segmented)
//                        .padding(.horizontal)
//                    }
//                    
//                    // Input Fields
//                    VStack(spacing: 15) {
//                        HStack(spacing: 15) {
//                            TextField("", text: $age, prompt: Text("Age").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.numberPad)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//                            
//                            TextField("", text: $weight, prompt: Text("Weight").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.decimalPad)
//                                .overlay(Text(unitSystem == .metric ? "kg" : "lb").padding(.trailing, 10), alignment: .trailing)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//                            
//                            TextField("", text: $height, prompt: Text("Height").foregroundStyle(.white.opacity(0.8)))
//                                .padding()
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .keyboardType(.decimalPad)
//                                .overlay(Text(unitSystem == .metric ? "cm" : "in").padding(.trailing, 10), alignment: .trailing)
//                                .foregroundColor(.white)
//                                .accentColor(.green)
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    // Calculate Button
////                    Button(action: {
////                        withAnimation(.easeInOut(duration: 1.0)) {
////                            bmi = calculatedBMI
////                            showResult = true
////                            animateGradient.toggle()
////                        }
////                    }) {
////                        Text("Calculate BMI")
////                            .frame(maxWidth: .infinity)
////                            .padding()
////                            .background((selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty) ? Color.gray : Color.orange)
////                            .foregroundColor(.white)
////                            .cornerRadius(10)
////                    }
////                    .disabled(selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty)
////                    .padding(.horizontal)
//                    // Buttons (Calculate BMI and Reset)
//                     HStack {
//                         // Calculate BMI Button
//                         Button(action: {
//                             withAnimation(.easeInOut(duration: 1.0)) {
//                                 bmi = calculatedBMI
//                                 showResult = true
//                                 animateGradient.toggle()
//                             }
//                         }) {
//                             Text("Calculate BMI")
//                                 .frame(maxWidth: .infinity)
//                                 .padding()
//                                 .background((selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty) ? Color.gray : Color.orange)
//                                 .foregroundColor(.white)
//                                 .cornerRadius(10)
//                         }
//                         .disabled(selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty)
//                         .padding(.trailing, 10)
//                         
//                         // Clear/Reset Button
//                         Button(action: {
//                             resetFields()
//                         }) {
//                             Text("Clear")
//                                 .frame(maxWidth: .infinity)
//                                 .padding()
//                                 .background(Color.red.opacity(0.4))
//                                 .foregroundColor(.white)
//                                 .cornerRadius(10)
//                         }
//                         .padding(.leading, 10)
//                     }
//                     .padding(.horizontal)
//                    
//                    // Animated Result Card
//                    if showResult {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 24, style: .continuous)
//                                .fill(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: animateGradient ? gradientColors.reversed() : gradientColors),
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    )
//                                )
//                                .opacity(0.4)
//                                .frame(maxWidth: 350, minHeight: 180)
//                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGradient)
//                            
//                            VStack(spacing: 12) {
//                                Text(String(format: "BMI: %.2f", bmi))
//                                    .font(.title)
//                                    .bold()
//                                    .foregroundColor(categoryColor)
//                                
//                                Text(category)
//                                    .font(.headline)
//                                    .foregroundColor(categoryColor)
//                                
//                                SemiCircleChart(bmi: bmi)
//                                    .frame(height: 220)
//                                    .padding(.top, 10)
//                            }
//                            .padding(.bottom, -30)
//                        }
//                        .transition(.opacity.combined(with: .scale))
//                    }
//                    
//                    // Spacer to push the buttons to the bottom
//                    Spacer()
//                    
//                    // Buttons at the bottom
//                    HStack {
//                        Button(action: {
//                            showResultsSheet = true
//                        }) {
//                            Text("Show Results")
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(showResult ? Color.blue : Color.blue.opacity(0.4))
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                                .padding(.bottom, 85)
//                        }
//                        .disabled(!showResult)
//                        .sheet(isPresented: $showResultsSheet) {
//                            BMIResultModal(
//                                timestamp: Date(),
//                                bmi: bmi,
//                                category: category,
//                                gender: selectedGender,
//                                age: age,
//                                activityLevel: selectedActivityLevel,
//                                heightInMeters: convertedHeight
//                            )
//                            .environmentObject(authService) // If you inject SupabaseAuthService here
//                            // .presentationDetents([.medium, .large])
//                            .presentationDragIndicator(.visible)    
//                        }
//
//                        Button(action: {
//                            print("Start Recommendation tapped")
//                        }) {
//                            Text("Start Recommendation")
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(showResult ? Color.green : Color.green.opacity(0.4))
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                                .padding(.bottom, 85)
//                        }
//                        .disabled(!showResult)
//                    }
//                    .padding(.horizontal, 20)
//                }
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                }
//                .foregroundColor(.white)
//            }
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color(hex: "#58B361"),
//                        Color(hex: "#264D2A")
//                    ]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//            )
//        }
//        .background(Color.clear)
//    }
//}
//
//// MARK: - Supporting Views for Gauge
//struct SemiCircleChart: View {
//    let bmi: Double
//    @State private var progress: Double = 0
//    let tickValues: [Double] = [10, 18.5, 25, 30, 40]
//    let tickLabels: [Double: String] = [
//        10: "Low", 18.5: "Under", 25: "Normal", 30: "Over", 40: "Obese"
//    ]
//    
//    var needleAngle: Angle {
//        let clampedBMI = min(max(bmi, 10), 40)
//        let percentage = (clampedBMI - 10) / 30
//        return .degrees(percentage * 180)
//    }
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .trim(from: 0.0, to: 0.5)
//                .stroke(Color.gray.opacity(0.2), lineWidth: 30)
//                .rotationEffect(.degrees(180))
//            
//            Circle()
//                .trim(from: 0.0, to: min(CGFloat(progress / 40), 0.5))
//                .stroke(AngularGradient(
//                    gradient: Gradient(colors: [.blue, .green, .orange, .red]),
//                    center: .center
//                ), style: StrokeStyle(lineWidth: 30, lineCap: .round))
//                .rotationEffect(.degrees(180))
//                .animation(.easeOut(duration: 1.0), value: progress)
//            
//            NeedleIndicator(angle: needleAngle)
//                .stroke(Color.black, lineWidth: 3)
//                .frame(width: 160, height: 160)
//                .animation(.easeInOut(duration: 1.0), value: needleAngle)
//            
//            VStack {
//                Text("BMI Gauge")
//                    .font(.caption)
//                Text(String(format: "%.1f", bmi))
//                    .font(.system(size: 36, weight: .bold))
//            }
//            .offset(y: 20)
//        }
//        .frame(height: 220)
//        .onAppear { progress = bmi }
//        .onChange(of: bmi) {_, newValue in progress = newValue }
//    }
//}
//
//struct NeedleIndicator: Shape {
//    var angle: Angle
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let radius = min(rect.width, rect.height) / 2
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let endX = center.x + radius * cos(CGFloat(angle.radians - .pi))
//        let endY = center.y + radius * sin(CGFloat(angle.radians - .pi))
//        path.move(to: center)
//        path.addLine(to: CGPoint(x: endX, y: endY))
//        return path
//    }
//}
//
//
//// Your BMIResultModal view (assuming it's the same as before)
//struct BMIResultModal: View {
//    @EnvironmentObject var authService: SupabaseAuthService
//
//    let timestamp: Date
//    let bmi: Double
//    let category: String
//    let gender: Gender?
//    let age: String
//    let activityLevel: ActivityLevel
//    let heightInMeters: Double
//
//    @State private var fullName: String = ""
//    @State private var userInitials: String = "US"
//
//    var formattedTimestamp: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter.string(from: timestamp)
//    }
//
//    var idealWeightRange: String {
//        let minWeight = 18.5 * heightInMeters * heightInMeters
//        let maxWeight = 24.9 * heightInMeters * heightInMeters
//        return String(format: "%.1f – %.1f kg", minWeight, maxWeight)
//    }
//
//    var healthTips: String {
//        switch category {
//        case "Underweight":
//            return """
//            You may benefit from a nutrient-rich, higher-calorie diet. \
//            Consulting a registered dietitian or healthcare provider can help you create a plan that supports your overall well-being.
//            """
//        case "Normal":
//            return """
//            Great job maintaining a healthy range! Keep focusing on balanced nutrition, regular activity, and self-care to support your ongoing health.
//            """
//        case "Overweight":
//            return """
//            Health is about more than weight. Consider adding enjoyable physical activity and mindful eating habits. Small, consistent steps matter.
//            """
//        case "Obese":
//            return """
//            Working with a healthcare provider can help you explore options tailored to your needs. Supportive, sustainable changes are key to long-term health.
//            """
//        default:
//            return "Note: BMI is just one indicator and may not reflect all aspects of your health. Always consult with a healthcare provider for personalized insights."
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Capsule()
//                .frame(width: 40, height: 5)
//                .foregroundColor(.gray.opacity(0.4))
//                .padding(.top, 10)
//
//            VStack(spacing: 4) {
//                Text("Body Mass Index Report")
//                    .font(.title2)
//                    .bold()
//
//                // Display full name without placeholder
//                Text("Generated for: \(fullName.isEmpty ? "Guest" : fullName)")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//
//                Text("Date: \(formattedTimestamp)")
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//            }
//
//            VStack(alignment: .leading, spacing: 12) {
//                infoRow(label: "BMI", value: String(format: "%.2f", bmi))
//                infoRow(label: "Category", value: category)
//                infoRow(label: "Ideal Weight Range", value: idealWeightRange)
//                infoRow(label: "Gender / Identity", value: gender?.rawValue ?? "Not specified")
//                infoRow(label: "Age", value: age)
//                infoRow(label: "Activity Level", value: activityLevel.label)
//
//                Divider()
//
//                Text("Health Considerations")
//                    .font(.headline)
//
//                Text(healthTips)
//                    .font(.body)
//                    .fixedSize(horizontal: false, vertical: true)
//
//                Text("Note: BMI is a generalized tool and may not reflect health in all individuals, including athletes, older adults, and people with diverse body types.")
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//                    .padding(.top, 8)
//            }
//            .padding()
//
//            Spacer()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(24)
//        .shadow(radius: 20)
//        .padding()
//        .onAppear {
//            fetchFullName()
//        }
//    }
//
//    // Fetch Full Name from Supabase Auth
//    private func fetchFullName() {
//        // Fetching real user from the authService
//        guard let user = authService.user else {
//            self.fullName = "Guest"
//            self.userInitials = "GG"
//            return
//        }
//
//        var first = ""
//        var last = ""
//
//        if let meta = user.userMetadata["first_name"], case let .string(value) = meta {
//            first = value
//        }
//        if let meta = user.userMetadata["last_name"], case let .string(value) = meta {
//            last = value
//        }
//
//        let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
//        let emailFallback = user.email ?? "User"
//
//        self.fullName = fullName.isEmpty ? emailFallback : fullName
//
//        if !first.isEmpty || !last.isEmpty {
//            let firstInitial = first.first.map { String($0).uppercased() } ?? ""
//            let lastInitial = last.first.map { String($0).uppercased() } ?? ""
//            self.userInitials = "\(firstInitial)\(lastInitial)"
//        } else if let email = user.email {
//            let parts = email.components(separatedBy: "@").first ?? ""
//            let chars = parts.prefix(2).uppercased()
//            self.userInitials = chars
//        } else {
//            self.userInitials = "US"
//        }
//    }
//
//    @ViewBuilder
//    func infoRow(label: String, value: String) -> some View {
//        HStack {
//            Text(label + ":")
//            Spacer()
//            Text(value)
//                .bold()
//                .foregroundColor(.primary)
//        }
//    }
//}
//
//
//// MARK: - Preview
//#Preview {
//    BMIView()
//        .environmentObject(SupabaseAuthService())
//}



import SwiftUI

// MARK: - Unit System Enum
enum UnitSystem: String, CaseIterable, Identifiable {
    case metric = "Metric (kg/cm)"
    case imperial = "Imperial (lb/in)"
    var id: String { self.rawValue }
}

// MARK: - Gender & ActivityLevel Enums
enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    var id: String { rawValue }
}

enum ActivityLevel: Int, CaseIterable, Identifiable {
    case inactive = 1, moderate = 2, active = 3
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .inactive: return "Inactive"
        case .moderate: return "Moderate"
        case .active: return "Active"
        }
    }
}

// MARK: - BMIResult Data Model
struct BMIResult: Identifiable {
    let id = UUID()
    let timestamp: Date
    let bmi: Double
    let category: String
    let gender: Gender?
    let age: String
    let activityLevel: ActivityLevel
    let heightInMeters: Double
}

// MARK: - Main BMI View
struct BMIView: View {
    @EnvironmentObject var authService: SupabaseAuthService

    @State private var unitSystem: UnitSystem = .metric
    @State private var selectedGender: Gender? = nil
    @State private var selectedActivityLevel: ActivityLevel = .moderate
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var bmi: Double = 0
    @State private var showResult = false
    @State private var animateGradient = false
    
    // New: Holds current BMIResult for modal
    @State private var selectedResult: BMIResult? = nil
    
    // MARK: - Conversion
    var convertedWeight: Double {
        guard let w = Double(weight) else { return 0 }
        return unitSystem == .metric ? w : w * 0.453592
    }
    
    var convertedHeight: Double {
        guard let h = Double(height) else { return 0 }
        return unitSystem == .metric ? h / 100 : h * 0.0254
    }
    
    var calculatedBMI: Double {
        let h = convertedHeight
        guard h > 0 else { return 0 }
        return convertedWeight / (h * h)
    }
    
    // MARK: - Adaptive BMI Classification
    func classifyBMI(bmiValue: Double, gender: Gender?, age: Int, activityLevel: ActivityLevel) -> String {
        guard !bmiValue.isNaN else { return "Unknown BMI" }
        guard let gender = gender else { return "Invalid Gender" }
        guard age >= 0 else { return "Invalid Age" }
        
        let genderStr = gender == .female ? "Female" : "Male"
        var thresholds: [String: Double] = [:]
        
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
        
        // Modify thresholds by activity
        switch activityLevel {
        case .inactive:
            thresholds["Normal"]! -= 1
            thresholds["Overweight"]! -= 1
        case .active:
            thresholds["Normal"]! += 1
            thresholds["Overweight"]! += 1
        default: break
        }
        
        // Modify thresholds by age
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
    
    // MARK: - Dynamic Category & Colors
    var category: String {
        let ageInt = Int(age) ?? -1
        return classifyBMI(
            bmiValue: bmi,
            gender: selectedGender,
            age: ageInt,
            activityLevel: selectedActivityLevel
        )
    }
    
    var categoryColor: Color {
        switch category {
        case "Underweight": return .blue
        case "Normal": return .green
        case "Overweight": return .orange
        case "Obese": return .red
        default: return .gray
        }
    }
    
    var gradientColors: [Color] {
        switch category {
        case "Underweight": return [Color.blue, Color.cyan]
        case "Normal": return [Color.green, Color.teal]
        case "Overweight": return [Color.orange, Color.yellow]
        case "Obese": return [Color.red, Color.pink]
        default: return [Color.gray, Color.gray.opacity(0.5)]
        }
    }
    
    // MARK: - Reset
    func resetFields() {
        selectedGender = nil
        selectedActivityLevel = .moderate
        age = ""
        weight = ""
        height = ""
        bmi = 0
        showResult = false
        animateGradient = false
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Title
                    Text("BMI Calculator")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 32)
                        .padding(.trailing, 160)
                    
                    // Gender + Unit Row
                    HStack(alignment: .top, spacing: 25) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Gender")
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack(spacing: 20) {
                                ForEach(Gender.allCases) { gender in
                                    Button(action: { selectedGender = gender }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: gender == .male ? "person" : "person.fill")
                                                .font(.title2)
                                            Text(gender.rawValue)
                                                .font(.caption)
                                        }
                                        .padding()
                                        .frame(width: 80, height: 80)
                                        .background(selectedGender == gender ? Color.green : Color.gray.opacity(0.4))
                                        .cornerRadius(12)
                                        .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        
                        // Unit System
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Unit System")
                                .font(.headline)
                                .foregroundColor(.white)
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(UnitSystem.allCases) { unit in
                                    Button(action: { unitSystem = unit }) {
                                        HStack {
                                            Image(systemName: unitSystem == unit ? "checkmark.circle.fill" : "circle")
                                            Text(unit.rawValue)
                                        }
                                        .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Activity Level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Activity Level")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                        
                        Divider().background(Color.white.opacity(0.5))
                        
                        Picker("Activity Level", selection: $selectedActivityLevel) {
                            ForEach(ActivityLevel.allCases) { activity in
                                Text(activity.label).tag(activity)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    
                    // Inputs
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            TextField("", text: $age, prompt: Text("Age").foregroundStyle(.white.opacity(0.8)))
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                            
                            TextField("", text: $weight, prompt: Text("Weight").foregroundStyle(.white.opacity(0.8)))
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .keyboardType(.decimalPad)
                                .overlay(Text(unitSystem == .metric ? "kg" : "lb").padding(.trailing, 10), alignment: .trailing)
                                .foregroundColor(.white)
                            
                            TextField("", text: $height, prompt: Text("Height").foregroundStyle(.white.opacity(0.8)))
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .keyboardType(.decimalPad)
                                .overlay(Text(unitSystem == .metric ? "cm" : "in").padding(.trailing, 10), alignment: .trailing)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Buttons (Calculate + Clear)
                    HStack {
                        Button("Calculate BMI") {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                bmi = calculatedBMI
                                showResult = true
                                animateGradient.toggle()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty) ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(selectedGender == nil || weight.isEmpty || height.isEmpty || age.isEmpty)
                        
                        Button("Clear") { resetFields() }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Result Card
                    if showResult {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: animateGradient ? gradientColors.reversed() : gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .opacity(0.4)
                                .frame(maxWidth: 350, minHeight: 180)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGradient)
                            
                            VStack(spacing: 12) {
                                Text(String(format: "BMI: %.2f", bmi))
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(categoryColor)
                                
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(categoryColor)
                                
                                SemiCircleChart(bmi: bmi)
                                    .frame(height: 220)
                                    .padding(.top, 10)
                            }
                            .padding(.bottom, -30)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                    // Bottom Buttons
                    HStack {
                        Button("Show Results") {
                            selectedResult = BMIResult(
                                timestamp: Date(),
                                bmi: bmi,
                                category: category,
                                gender: selectedGender,
                                age: age,
                                activityLevel: selectedActivityLevel,
                                heightInMeters: convertedHeight
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(showResult ? Color.blue : Color.blue.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 85)
                        .disabled(!showResult)
                        
                        Button("Start Recommendation") {
                            print("Start Recommendation tapped")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(showResult ? Color.green : Color.green.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 85)
                        .disabled(!showResult)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#58B361"), Color(hex: "#264D2A")]),
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            )
        }
        // Sheet presentation for result modal
        .sheet(item: $selectedResult) { result in
            BMIResultModal(
                timestamp: result.timestamp,
                bmi: result.bmi,
                category: result.category,
                gender: result.gender,
                age: result.age,
                activityLevel: result.activityLevel,
                heightInMeters: result.heightInMeters
            )
            .environmentObject(authService)
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Supporting Views
struct SemiCircleChart: View {
    let bmi: Double
    @State private var progress: Double = 0
    var needleAngle: Angle {
        let clampedBMI = min(max(bmi, 10), 40)
        let percentage = (clampedBMI - 10) / 30
        return .degrees(percentage * 180)
    }
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.gray.opacity(0.2), lineWidth: 30)
                .rotationEffect(.degrees(180))
            
            Circle()
                .trim(from: 0.0, to: min(CGFloat(progress / 40), 0.5))
                .stroke(AngularGradient(
                    gradient: Gradient(colors: [.blue, .green, .orange, .red]),
                    center: .center
                ), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .rotationEffect(.degrees(180))
                .animation(.easeOut(duration: 1.0), value: progress)
            
            NeedleIndicator(angle: needleAngle)
                .stroke(Color.black, lineWidth: 3)
                .frame(width: 160, height: 160)
                .animation(.easeInOut(duration: 1.0), value: needleAngle)
            
            VStack {
                Text("BMI Gauge").font(.caption)
                Text(String(format: "%.1f", bmi))
                    .font(.system(size: 36, weight: .bold))
            }
            .offset(y: 20)
        }
        .frame(height: 220)
        .onAppear { progress = bmi }
        .onChange(of: bmi) { _, newValue in progress = newValue }
    }
}

struct NeedleIndicator: Shape {
    var angle: Angle
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let endX = center.x + radius * cos(CGFloat(angle.radians - .pi))
        let endY = center.y + radius * sin(CGFloat(angle.radians - .pi))
        path.move(to: center)
        path.addLine(to: CGPoint(x: endX, y: endY))
        return path
    }
}

// MARK: - BMI Result Modal
struct BMIResultModal: View {
    @EnvironmentObject var authService: SupabaseAuthService

    let timestamp: Date
    let bmi: Double
    let category: String
    let gender: Gender?
    let age: String
    let activityLevel: ActivityLevel
    let heightInMeters: Double

    @State private var fullName: String = ""
    @State private var userInitials: String = "US"

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var idealWeightRange: String {
        let minWeight = 18.5 * heightInMeters * heightInMeters
        let maxWeight = 24.9 * heightInMeters * heightInMeters
        return String(format: "%.1f – %.1f kg", minWeight, maxWeight)
    }

    var healthTips: String {
        switch category {
        case "Underweight":
            return "You may benefit from a nutrient-rich, higher-calorie diet. Consulting a registered dietitian or healthcare provider can help you create a plan that supports your overall well-being."
        case "Normal":
            return "Great job maintaining a healthy range! Keep focusing on balanced nutrition, regular activity, and self-care to support your ongoing health."
        case "Overweight":
            return "Health is about more than weight. Consider adding enjoyable physical activity and mindful eating habits. Small, consistent steps matter."
        case "Obese":
            return "Working with a healthcare provider can help you explore options tailored to your needs. Supportive, sustainable changes are key to long-term health."
        default:
            return "BMI is just one indicator and may not reflect all aspects of your health. Always consult with a healthcare provider for personalized insights."
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 10)

            VStack(spacing: 4) {
                Text("Body Mass Index Report").font(.title2).bold()
                Text("Generated for: \(fullName.isEmpty ? "Guest" : fullName)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Date: \(formattedTimestamp)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 12) {
                infoRow(label: "BMI", value: String(format: "%.2f", bmi))
                infoRow(label: "Category", value: category)
                infoRow(label: "Ideal Weight Range", value: idealWeightRange)
                infoRow(label: "Gender", value: gender?.rawValue ?? "Not specified")
                infoRow(label: "Age", value: age)
                infoRow(label: "Activity Level", value: activityLevel.label)

                Divider()
                Text("Health Considerations").font(.headline)
                Text(healthTips)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 20)
        .padding()
        .onAppear { fetchFullName() }
    }

    private func fetchFullName() {
        guard let user = authService.user else {
            self.fullName = "Guest"
            return
        }

        var first = ""
        var last = ""

        if let meta = user.userMetadata["first_name"], case let .string(value) = meta {
            first = value
        }
        if let meta = user.userMetadata["last_name"], case let .string(value) = meta {
            last = value
        }

        let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        self.fullName = fullName.isEmpty ? (user.email ?? "User") : fullName
    }

    @ViewBuilder
    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
            Spacer()
            Text(value).bold()
        }
    }
}

#Preview {
    BMIView().environmentObject(SupabaseAuthService())
}
