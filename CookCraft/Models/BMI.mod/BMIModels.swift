//
//  BMIModels.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 28/10/2025.
//

import Foundation

// MARK: - RPC Return Types (bmi_results_view rows)
struct DBBMIResultView: Codable, Identifiable {
    let id: Int64
    let userId: UUID
    let measuredAt: Date
    let gender: String?
    let ageYears: Int?
    let activity: String          // 'inactive' | 'moderate' | 'active'
    let unitSystem: String        // 'metric' | 'imperial' (input provenance)
    let weightKg: Double
    let heightM: Double
    let bmi: Double
    let category: String          // 'Underweight' | 'Normal' | 'Overweight' | 'Obese' | error strings
    let idealWeightMinKg: Double
    let idealWeightMaxKg: Double
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Enum Bridges (Swift ↔ DB)
enum DBGender: String {
    case female = "Female"
    case male   = "Male"
    case nonBinary = "Non-binary"
    case other = "Other"
    case preferNot = "Prefer not to say"
}

extension UnitSystem {
    var dbValue: String { self == .metric ? "metric" : "imperial" }
}

extension ActivityLevel {
    var dbValue: String {
        switch self {
        case .inactive: return "inactive"
        case .moderate: return "moderate"
        case .active:   return "active"
        }
    }
}

extension Gender {
    var dbValue: String {
        switch self {
        case .female: return "Female"
        case .male:   return "Male"
        }
    }
}
