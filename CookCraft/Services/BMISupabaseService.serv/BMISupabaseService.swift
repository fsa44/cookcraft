//
//  BMISupabaseService.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 28/10/2025.
//

import Foundation
import Supabase

final class BMISupabaseService {
    private let client: SupabaseClient
    private let decoder: JSONDecoder

    init(client: SupabaseClient = supabase) {
        self.client = client
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        // Flexible ISO8601 with fractional seconds
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            let f1 = ISO8601DateFormatter()
            f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = f1.date(from: str) { return d }
            let f2 = ISO8601DateFormatter()
            f2.formatOptions = [.withInternetDateTime]
            if let d = f2.date(from: str) { return d }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(str)")
        }
    }

    // MARK: - Create
    @discardableResult
    func createBMIResult(
        measuredAt: Date = Date(),
        weight: Double,
        height: Double,
        unit: UnitSystem,
        activity: ActivityLevel,
        gender: Gender?,
        age: Int?
    ) async throws -> DBBMIResultView {
        struct Params: Encodable {
            let p_measured_at: String
            let p_weight: Double
            let p_height: Double
            let p_unit: String
            let p_activity: String
            let p_gender: String?
            let p_age: Int?
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let params = Params(
            p_measured_at: iso.string(from: measuredAt),
            p_weight: weight,
            p_height: height,
            p_unit: unit.dbValue,
            p_activity: activity.dbValue,
            p_gender: gender?.dbValue,
            p_age: age
        )

        // Call RPC and decode
        let response = try await client
            .rpc("set_my_bmi_result", params: params)
            .execute()

        return try decoder.decode(DBBMIResultView.self, from: response.data)
    }

    // MARK: - Read (paged)
    func getMyBMIResults(
        start: Date? = nil,
        end: Date? = nil,
        limit: Int = 100,
        offset: Int = 0
    ) async throws -> [DBBMIResultView] {
        struct Params: Encodable {
            let p_start: String?
            let p_end: String?
            let p_limit: Int
            let p_offset: Int
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let params = Params(
            p_start: start.map { iso.string(from: $0) },
            p_end:   end.map { iso.string(from: $0) },
            p_limit: limit,
            p_offset: offset
        )

        let response = try await client
            .rpc("get_my_bmi_results", params: params)
            .execute()

        return try decoder.decode([DBBMIResultView].self, from: response.data)
    }

    // MARK: - Read (latest)
    func getMyLatestBMI() async throws -> DBBMIResultView? {
        let response = try await client
            .rpc("get_my_latest_bmi")
            .execute()

        if response.data.isEmpty { return nil }
        return try decoder.decode(DBBMIResultView.self, from: response.data)
    }

    // MARK: - Delete
    func deleteMyBMIResult(id: Int64) async throws {
        struct Params: Encodable { let p_id: Int64 }
        _ = try await client
            .rpc("delete_my_bmi_result", params: Params(p_id: id))
            .execute()
    }
}
