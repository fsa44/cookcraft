//////
//////  RecipeService.swift
//////  CookCraft
//////
//////  Created by Fatmasarah Abdikadir on 11/11/2025.
//////
//

import Foundation
import Supabase

// Ensure your Recipe model has: var mealType: String?
// struct Recipe: Codable, Identifiable { ... var mealType: String? ... }

enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case dessert = "Dessert"
}

struct RecipeService {
    private let supabase = SupabaseClient(
                supabaseURL: URL(string: "https://hlskjfdzrvoayettclsn.supabase.co")!,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsc2tqZmR6cnZvYXlldHRjbHNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MDU2NTEsImV4cCI6MjA3NjM4MTY1MX0.oQJ9MI5QzYNj8HnQvN7U_R-0zvjWDrKxZk5ul_8wZ44"
    )

    private let bucketName = "recipe_enriched"

    // Local cache folder for downloaded JSON files
    private let cacheDirectory: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = dir.appendingPathComponent("RecipeCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }()

    // MARK: - Normalization helpers (case/diacritic-insensitive)
    private func normalize(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive],
                  locale: Locale(identifier: "en"))
         .lowercased()
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func matchesMealType(_ recipe: Recipe, required: MealType) -> Bool {
        guard let mt = recipe.mealType else { return false }
        return normalize(mt) == normalize(required.rawValue)
    }

    // MARK: - Load & cache any recipes JSON
    private func loadRecipesFile(_ file: String) async throws -> [Recipe] {
        let bucket = supabase.storage.from(bucketName)
        let cachedURL = cacheDirectory.appendingPathComponent(file)
        let data: Data

        if FileManager.default.fileExists(atPath: cachedURL.path) {
            data = try Data(contentsOf: cachedURL)
        } else {
            data = try await bucket.download(path: file)
            try? data.write(to: cachedURL, options: .atomic)
        }

        return try JSONDecoder().decode([Recipe].self, from: data)
    }

    // MARK: - Strict category fetcher (only exact mealType)
    func fetchCategoryRecipesStrict(
        categoryFile: String,
        categoryName: String,
        requiredMealType: MealType,
        completion: @escaping ([Recipe]) -> Void
    ) {
        Task {
            let bucket = supabase.storage.from(bucketName)
            let culturalFile = "cultural_meals_enriched.json"

            do {
                // --- Cultural meals (cached) ---
                let culturalCachedURL = cacheDirectory.appendingPathComponent(culturalFile)
                let culturalData: Data
                if FileManager.default.fileExists(atPath: culturalCachedURL.path) {
                    culturalData = try Data(contentsOf: culturalCachedURL)
                } else {
                    culturalData = try await bucket.download(path: culturalFile)
                    try? culturalData.write(to: culturalCachedURL, options: .atomic)
                }

                var culturalRecipes = try JSONDecoder().decode([Recipe].self, from: culturalData)
                culturalRecipes = culturalRecipes.filter { matchesMealType($0, required: requiredMealType) }

                // --- Category file (cached) ---
                let categoryCachedURL = cacheDirectory.appendingPathComponent(categoryFile)
                let categoryData: Data
                if FileManager.default.fileExists(atPath: categoryCachedURL.path) {
                    categoryData = try Data(contentsOf: categoryCachedURL)
                } else {
                    categoryData = try await bucket.download(path: categoryFile)
                    try? categoryData.write(to: categoryCachedURL, options: .atomic)
                }

                var categoryRecipes = try JSONDecoder().decode([Recipe].self, from: categoryData)
                categoryRecipes = categoryRecipes.filter { matchesMealType($0, required: requiredMealType) }

                // Optional: tag the UI category name
                categoryRecipes = categoryRecipes.map {
                    var r = $0
                    r.category = categoryName
                    return r
                }

                // Combine strictly filtered lists
                var combined = culturalRecipes + categoryRecipes

                // De-duplicate by name (use id if you have a stable one)
                var seen = Set<String>()
                combined = combined.filter { r in
                    let key = r.name.lowercased()
                    if seen.contains(key) { return false }
                    seen.insert(key); return true
                }

                let results = combined // Make an immutable copy for clarity
                await MainActor.run {
                    completion(results)
                }
            } catch {
                print("Failed strict load \(categoryFile) or cultural meals: \(error)")
                await MainActor.run { completion([]) }
            }
        }
    }

    // MARK: - All-recipes (used by search)
    func fetchAllRecipes(completion: @escaping ([Recipe]) -> Void) {
        Task {
            let files = [
                "cultural_meals_enriched.json",
                "recipes_breakfast_part0.json",
                "recipes_lunch_part0.json",
                "recipes_dinner_part0.json",
                "recipes_snack_part0.json",
                "recipes_dessert_part0.json"
            ]

            do {
                var all: [Recipe] = []

                try await withThrowingTaskGroup(of: [Recipe].self) { group in
                    for f in files {
                        group.addTask {
                            do { return try await loadRecipesFile(f) }
                            catch { print("Skipped file \(f): \(error)"); return [] }
                        }
                    }
                    for try await batch in group { all.append(contentsOf: batch) }
                }

                // De-duplicate by name (prefer id if available)
                var seen = Set<String>()
                let unique = all.filter { r in
                    let key = r.name.lowercased()
                    if seen.contains(key) { return false }
                    seen.insert(key); return true
                }

                await MainActor.run { completion(unique) }
            } catch {
                print("fetchAllRecipes failed: \(error)")
                await MainActor.run { completion([]) }
            }
        }
    }

    // (Optional legacy) Non-strict category fetch retained if needed elsewhere
    func fetchCategoryRecipes(categoryFile: String, categoryName: String, completion: @escaping ([Recipe]) -> Void) {
        Task {
            let bucket = supabase.storage.from(bucketName)
            let culturalFile = "cultural_meals_enriched.json"

            do {
                let culturalCachedURL = cacheDirectory.appendingPathComponent(culturalFile)
                let culturalData: Data
                if FileManager.default.fileExists(atPath: culturalCachedURL.path) {
                    culturalData = try Data(contentsOf: culturalCachedURL)
                } else {
                    culturalData = try await bucket.download(path: culturalFile)
                    try? culturalData.write(to: culturalCachedURL, options: .atomic)
                }

                var culturalRecipes = try JSONDecoder().decode([Recipe].self, from: culturalData)
                culturalRecipes = culturalRecipes.filter {
                    $0.category == nil || $0.category == categoryName
                }

                let categoryCachedURL = cacheDirectory.appendingPathComponent(categoryFile)
                let categoryData: Data
                if FileManager.default.fileExists(atPath: categoryCachedURL.path) {
                    categoryData = try Data(contentsOf: categoryCachedURL)
                } else {
                    categoryData = try await bucket.download(path: categoryFile)
                    try? categoryData.write(to: categoryCachedURL, options: .atomic)
                }

                var categoryRecipes = try JSONDecoder().decode([Recipe].self, from: categoryData)
                categoryRecipes = categoryRecipes.map {
                    var r = $0
                    r.category = categoryName
                    return r
                }

                let chosenCultural = culturalRecipes.shuffled().prefix(7)
                let chosenCategory = categoryRecipes.shuffled().prefix(5)
                let combined = Array(chosenCultural) + Array(chosenCategory)

                await MainActor.run { completion(combined) }
            } catch {
                print("Failed to load \(categoryFile) or cultural meals: \(error)")
                await MainActor.run { completion([]) }
            }
        }
    }
}
