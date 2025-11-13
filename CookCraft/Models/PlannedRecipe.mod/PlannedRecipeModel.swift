//
//  PlannedRecipeModel.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 12/11/2025.
//


import Foundation

struct PlannedRecipe: Identifiable {
    let id = UUID()
    let recipe: Recipe
    var assignedDays: Set<String> = []
}
