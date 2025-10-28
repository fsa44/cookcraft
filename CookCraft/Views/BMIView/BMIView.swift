import SwiftUI
import Supabase

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

// MARK: - BMIResult Data Model (UI-only)
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
    @State private var isSaving = false
    @State private var saveError: String?

    // New: Holds current BMIResult for modal
    @State private var selectedResult: BMIResult? = nil

    private let bmiService = BMISupabaseService()

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
        saveError = nil
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
                                saveError = nil
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
                        .transition(.opacity .combined(with: .scale))

                        if let saveError {
                            Text(saveError)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 6)
                        }
                    }

                    // Bottom Buttons
                    HStack {
                        // Save to DB and show modal
                        Button(action: {
                            guard showResult else { return }
                            isSaving = true
                            saveError = nil

                            Task {
                                do {
                                    let dbRow = try await bmiService.createBMIResult(
                                        measuredAt: Date(),
                                        weight: Double(weight) ?? 0,
                                        height: Double(height) ?? 0,
                                        unit: unitSystem,
                                        activity: selectedActivityLevel,
                                        gender: selectedGender,
                                        age: Int(age)
                                    )

                                    self.selectedResult = BMIResult(
                                        timestamp: dbRow.measuredAt,
                                        bmi: dbRow.bmi,
                                        category: dbRow.category,
                                        gender: selectedGender,
                                        age: age,
                                        activityLevel: selectedActivityLevel,
                                        heightInMeters: dbRow.heightM
                                    )
                                } catch {
                                    self.saveError = "Could not save BMI result. Please try again."
                                    print("Save BMI error: \(error)")
                                }
                                isSaving = false
                            }
                        }) {
                            HStack {
                                if isSaving { ProgressView().tint(.white) }
                                Text("Show Results")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(showResult ? Color.blue : Color.blue.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 85)
                        .disabled(!showResult || isSaving)

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
        return path;
    }
}

// MARK: - BMI Result Modal (from your existing code)
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

// MARK: - Small hex color helper used above
//extension Color {
//    init(hex: String) {
//        let hex = hex.replacingOccurrences(of: "#", with: "")
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let r, g, b: Double
//        switch hex.count {
//        case 6:
//            r = Double((int >> 16) & 0xFF) / 255
//            g = Double((int >> 8) & 0xFF) / 255
//            b = Double(int & 0xFF) / 255
//        default:
//            r = 1; g = 1; b = 1
//        }
//        self = Color(red: r, green: g, blue: b)
//    }
//}

#Preview {
    BMIView().environmentObject(SupabaseAuthService())
}
