//
//  NutritionArticle.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 19/11/2025.
//

import Foundation

struct NutritionArticle: Identifiable, Equatable {
    let id: String           // unique id, e.g. file path / name from Supabase
    let title: String        // article name
    let imageURL: URL?       // public URL for the infographic image
}
