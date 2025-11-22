//
//  StoryRecommendationView.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 22/11/2025.
//






import SwiftUI

struct StoryRecommendationView: View {
    let response: PredictResponse
    let bmi: Double
    let goal: String


    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    headerSection

                    Divider()

                    storyTextSection

                    Divider()

                    shapSection

                    Divider()

                    mealsSection
                }
                .padding()
            }
            .navigationTitle("Your Plan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Personalized Nutrition Story")
                .font(.title2).bold()

            Text(
                "Because your BMI is **\(response.prediction.bmiCategory)** (BMI \(String(format: "%.1f", bmi))) and your goal is **\(goal)**, we’ve created a gentle, student-friendly plan to support you."
            )
            .font(.body)
            .foregroundColor(.secondary)
        }
    }

    private var storyTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why this plan?")
                .font(.headline)

            Text(response.mealRecommendations.storyText)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var shapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What influenced this suggestion?")
                .font(.headline)

            // Local SHAP explanation
            VStack(alignment: .leading, spacing: 6) {
                Text("Most influential factors for this prediction:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(response.explanations.local.topFeatures.prefix(3)) { feature in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(feature.feature)
                                .font(.subheadline).bold()
                            Text(
                                feature.shapValue >= 0
                                ? "Pushed prediction **towards** \(response.prediction.bmiCategory)"
                                : "Pushed prediction **away from** \(response.prediction.bmiCategory)"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.3f", feature.shapValue))
                            .font(.caption)
                            .padding(6)
                            .background(
                                feature.shapValue >= 0 ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2)
                            )
                            .cornerRadius(8)
                    }
                }
            }
            probabilitiesSection   // <- show model confidence
        }
    }

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested Meals")
                .font(.headline)

            mealGroup(title: "Breakfast", meals: response.mealRecommendations.slots.breakfast)
            mealGroup(title: "Lunch", meals: response.mealRecommendations.slots.lunch)
            mealGroup(title: "Dinner", meals: response.mealRecommendations.slots.dinner)
            mealGroup(title: "Snacks", meals: response.mealRecommendations.slots.snack)
        }
    }
    
    private var probabilitiesSection: some View {
        let probs = response.prediction.sortedProbabilities

        return Group {
            if !probs.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("How confident is this prediction?")
                        .font(.headline)

                    ForEach(probs.prefix(4), id: \.0) { (label, value) in
                        HStack {
                            Text(label)
                            Spacer()
                            Text(String(format: "%.1f%%", value * 100))
                                .bold()
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }


    private func mealGroup(title: String, meals: [MealDTO]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if meals.isEmpty {
                Text("No specific \(title.lowercased()) suggestions yet. You can still follow the general guidance above.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(meals) { meal in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meal.title)
                            .font(.subheadline).bold()

                        if let description = meal.description, !description.isEmpty {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 8) {
                            if let calories = meal.displayCalories {
                                TagView(text: calories)
                            }
                            if let diet = meal.dietPreference {
                                TagView(text: diet)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.green.opacity(0.15))
            .cornerRadius(999)
    }
}

