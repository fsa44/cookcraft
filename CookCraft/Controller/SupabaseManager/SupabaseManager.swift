//
//  SupabaseManager.swift
//  CookCraft
//
//  Created by Fatmasarah Abdikadir on 19/11/2025.
//

// SupabaseManager.swift
import Foundation
import Supabase

enum SupabaseManager {
    static let shared = SupabaseClient(
        supabaseURL: URL(string: "https://hlskjfdzrvoayettclsn.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhsc2tqZmR6cnZvYXlldHRjbHNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MDU2NTEsImV4cCI6MjA3NjM4MTY1MX0.oQJ9MI5QzYNj8HnQvN7U_R-0zvjWDrKxZk5ul_8wZ44"
    )
}
