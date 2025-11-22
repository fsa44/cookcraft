//
//  RecommendationStore.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 22/11/2025.
//

import Foundation
import Combine

final class RecommendationStore: ObservableObject {
    @Published var latestResponse: PredictResponse?
}
