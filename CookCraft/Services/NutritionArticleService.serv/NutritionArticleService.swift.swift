//
//  ArticleService.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 19/11/2025.
//

import Foundation
import Supabase

final class NutritionArticleService {

    static let shared = NutritionArticleService()

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.shared) {
        self.client = client
    }

    /// Fetches infographic articles from the "Nutritional Articles" bucket.
    /// Assumes the file name (without extension) is the "title".
    func fetchArticles() async throws -> [NutritionArticle] {
        let bucketName = "Nutritional Articles"

        // List all files in bucket root (adjust path if you use subfolders)
        let files = try await client.storage
            .from(bucketName)
            .list(path: "", options: .init(limit: 100))
       
        print("Fetched files:", files)
        print("Count:", files.count)

        let articles: [NutritionArticle] = files.map { file in
            let path = file.name

            // getPublicURL can throw in this SDK, so use try?
            let publicURL = try? client.storage
                .from(bucketName)
                .getPublicURL(path: path)

            // Use filename without extension as title fallback
            let rawTitle = (path as NSString).deletingPathExtension
            let title = rawTitle
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")

            return NutritionArticle(
                id: path,
                title: title.isEmpty ? "Nutrition Article" : title,
                imageURL: publicURL   // URL? – safe even if publicURL is nil
            )
        }

        return articles
    }
}
