//
//  BMIRecommendationService.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 22/11/2025.
//

//
//  BMIRecommendationService.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 21/11/2025.
//

import Foundation

final class BMIRecommendationService {
    static let shared = BMIRecommendationService()

    // TODO: Replace with your actual backend URL
    // Example: "https://cookcraft-api.yourdomain.com"
    private let baseURL = URL(string: "http://localhost:8000")! // Alternative - http://127.0.0.1:8000

    private let urlSession: URLSession
     private let encoder: JSONEncoder
     private let decoder: JSONDecoder

     init() {
         self.urlSession = .shared

         let enc = JSONEncoder()
         enc.keyEncodingStrategy = .convertToSnakeCase
         self.encoder = enc

         let dec = JSONDecoder()
         dec.keyDecodingStrategy = .convertFromSnakeCase
         self.decoder = dec
     }

     func predictAndExplain(request: BMIPredictRequest) async throws -> PredictResponse {
         let url = baseURL.appendingPathComponent("predict_and_explain/")

         var urlRequest = URLRequest(url: url)
         urlRequest.httpMethod = "POST"
         urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
         urlRequest.httpBody = try encoder.encode(request)

         let (data, response) = try await urlSession.data(for: urlRequest)

         guard let http = response as? HTTPURLResponse else {
             throw URLError(.badServerResponse)
         }

         guard (200..<300).contains(http.statusCode) else {
             let bodyString = String(data: data, encoding: .utf8) ?? "<no body>"
             print("FastAPI error \(http.statusCode): \(bodyString)")
             throw NSError(
                 domain: "BMIRecommendationService",
                 code: http.statusCode,
                 userInfo: [NSLocalizedDescriptionKey: "Backend error \(http.statusCode)"]
             )
         }
         
         // Optional: debug print of successful JSON
         // print("API response:", String(data: data, encoding: .utf8) ?? "<no body>")

         return try decoder.decode(PredictResponse.self, from: data)
     }
 }
