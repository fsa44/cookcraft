////
////  BMIRecommendationModels.swift
////  CookCraft
////
////  Created by Fatmasarah Abdikadir on 22/11/2025.
////
//
//
////
////  BMIRecommendationModels.swift
////  CookCraft
////
////  Created by Fatmasarah Abdikadir on 21/11/2025.
////
//
////
////  BMIRecommendationModels.swift
////  CookCraft
////
//
//import Foundation
//
//// MARK: - Request sent to FastAPI
//
//struct BMIPredictRequest: Encodable {
//    let age: Int
//    let gender: String
//    let bmi: Double
//    let heightCm: Double
//    let weightKg: Double
//    let activityLevel: String
//    let dietPreference: String?
//    let goal: String?
//    let allergies: String?
//}
//
//// MARK: - Top-level response
//
//struct PredictResponse: Decodable {
//    let prediction: PredictionDTO
//    let explanations: ExplanationsDTO
//    let mealRecommendations: MealRecommendationsDTO
//}
//
//// MARK: - Prediction
//
//struct PredictionDTO: Decodable {
//    let bmiCategory: String
//    let numericBmi: Double?
//    /// Optional because backend may not return it yet
//    let classProbabilities: [String: Double]?
//
//    /// Convenience for UI (safe even if nil)
//    var sortedProbabilities: [(String, Double)] {
//        (classProbabilities ?? [:]).sorted { $0.value > $1.value }
//    }
//}
//
//// MARK: - Explanations
//
//struct ExplanationsDTO: Decodable {
//    let local: LocalExplanationDTO
//    let global: GlobalExplanationDTO
//}
//
//struct LocalExplanationDTO: Decodable {
//    let predictedClass: String
//    let topFeatures: [LocalFeatureDTO]
//}
//
//struct LocalFeatureDTO: Decodable, Identifiable {
//    var id: String { feature }
//
//    let feature: String
//    let shapValue: Double
//    let absShap: Double
//}
//
//struct GlobalExplanationDTO: Decodable {
//    let topFeatures: [GlobalFeatureDTO]
//}
//
//struct GlobalFeatureDTO: Decodable, Identifiable {
//    var id: String { feature }
//
//    let feature: String
//    let meanAbsShap: Double
//}
//
//// MARK: - Meal Recommendations
//
//struct MealRecommendationsDTO: Decodable {
//    let storyText: String
//    let slots: MealSlotsDTO
//}
//
//struct MealSlotsDTO: Decodable {
//    let breakfast: [MealDTO]
//    let lunch: [MealDTO]
//    let dinner: [MealDTO]
//    let snack: [MealDTO]
//}
//
//struct MealDTO: Decodable, Identifiable {
//    let id: String?
//    let title: String
//    let description: String?
//    let calories: Int?
//    let dietPreference: String?
//    let bmiSuitability: [String]?
//
//    var displayCalories: String? {
//        guard let calories else { return nil }
//        return "\(calories) kcal"
//    }
//}


import Foundation

// MARK: - Root response

/// Request body sent from iOS → FastAPI `/predict_and_explain/`

struct BMIPredictRequest: Encodable {
    let age: Int
    let gender: String
    let bmi: Double
    let heightCm: Double
    let weightKg: Double
    let activityLevel: String

    // Optional context
    let medicalConditions: String?
    let dietPreference: String?
    let goal: String?
    let region: String?
    let yearOfStudy: Int?
    let budgetLevel: String?
    let cookingSkill: String?
    let internetAccess: String?
    let culturalPreference: String?
    let foodAvailability: String?
    let academicSchedule: String?
    let mealFrequency: String?
    let allergies: String?
    let planFollowed: String?
    let outcome: String?

    // NEW
    let userId: String?

    init(
        age: Int,
        gender: String,
        bmi: Double,
        heightCm: Double,
        weightKg: Double,
        activityLevel: String,
        dietPreference: String? = nil,
        goal: String? = nil,
        allergies: String? = nil,
        medicalConditions: String? = nil,
        region: String? = nil,
        yearOfStudy: Int? = nil,
        budgetLevel: String? = nil,
        cookingSkill: String? = nil,
        internetAccess: String? = nil,
        culturalPreference: String? = nil,
        foodAvailability: String? = nil,
        academicSchedule: String? = nil,
        mealFrequency: String? = nil,
        planFollowed: String? = nil,
        outcome: String? = nil,
        userId: String? = nil
    ) {
        self.age = age
        self.gender = gender
        self.bmi = bmi
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.activityLevel = activityLevel

        self.medicalConditions = medicalConditions
        self.dietPreference = dietPreference
        self.goal = goal
        self.region = region
        self.yearOfStudy = yearOfStudy
        self.budgetLevel = budgetLevel
        self.cookingSkill = cookingSkill
        self.internetAccess = internetAccess
        self.culturalPreference = culturalPreference
        self.foodAvailability = foodAvailability
        self.academicSchedule = academicSchedule
        self.mealFrequency = mealFrequency
        self.allergies = allergies
        self.planFollowed = planFollowed
        self.outcome = outcome
        self.userId = userId
    }
}


// PredictResponse

struct PredictResponse: Decodable {
    let prediction: PredictionDTO
    let explanations: ExplanationsDTO
    let mealRecommendations: MealRecommendationsDTO
}

// MARK: - Prediction

struct PredictionDTO: Decodable {
    let bmiCategory: String
    let numericBmi: Double?
    let classProbabilities: [String: Double]?

    var sortedProbabilities: [(String, Double)] {
        (classProbabilities ?? [:]).sorted { $0.value > $1.value }
    }
}

// MARK: - Explanations

struct ExplanationsDTO: Decodable {
    let local: LocalExplanationDTO
    let global: GlobalExplanationDTO
}

struct LocalExplanationDTO: Decodable {
    let predictedClass: String
    let topFeatures: [ShapFeatureDTO]
}

struct GlobalExplanationDTO: Decodable {
    let topFeatures: [ShapFeatureDTO]
}

struct ShapFeatureDTO: Decodable, Identifiable {
    let feature: String
    let rawName: String?
    let shapValue: Double
    let absShap: Double

    var id: String { rawName ?? feature }
}

// MARK: - Meal recommendations

struct MealRecommendationsDTO: Decodable {
    let storyText: String
    let slots: MealSlotsDTO
}

struct MealSlotsDTO: Decodable {
    let breakfast: [MealDTO]
    let lunch: [MealDTO]
    let dinner: [MealDTO]
    let snack: [MealDTO]
}

// MARK: - Meal DTO

struct MealDTO: Decodable, Identifiable {
    let id: String?
    let name: String?
    let description: String?
    let image: String?
    let url: String?
    let mealType: String?
    let dietTags: [String]
    let healthScore: Int?
    let isHealthy: Bool?
    let source: String?

    // Convenience for UI
    var title: String {
        name ?? "Suggested meal"
    }

    var displayCalories: String? {
        // If your JSON later includes calories, you can format them here.
        // For now we return nil so the tag is optional.
        return nil
    }

    var dietPreference: String? {
        dietTags.first
    }
}


