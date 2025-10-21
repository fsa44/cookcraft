//
//  SupabaseClient.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 21/10/2025.
//
//
//  SupabaseClient.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 21/10/2025.
//

import Foundation
import Supabase

/// Single shared Supabase client for the whole app.
/// Make sure there is **no other `supabase` global** anywhere else in the project.
public let supabase: SupabaseClient = {
    // Prefer Info.plist keys; fallback to hardcoded values
    let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        ?? "https://hlskjfdzrvoayettclsn.supabase.co"   // <-- your real URL
    let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        ?? "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsc2tqZmR6cnZvYXlldHRjbHNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MDU2NTEsImV4cCI6MjA3NjM4MTY1MX0.oQJ9MI5QzYNj8HnQvN7U_R-0zvjWDrKxZk5ul_8wZ44"

    guard let url = URL(string: urlString) else {
        fatalError("❌ Invalid SUPABASE_URL: \(urlString)")
    }

    // Use the broadest-compatible initializer for the SDK you have installed.
    return SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}()
