//
//  Supabase.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 13/1/2026.
//
import Supabase
import Foundation

enum Secrets {
    static var supabaseURL: URL {
        let debugValue = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL")
        print("DEBUG SUPABASE_URL =", debugValue ?? "nil")

        guard let raw = debugValue as? String,
              !raw.isEmpty
        else {
            fatalError("SUPABASE_URL not found. Check Info.plist and Secrets.xcconfig.")
        }

        let value = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))

        guard let url = URL(string: value) else {
            fatalError("SUPABASE_URL is not a valid URL: \(value)")
        }
        guard url.scheme == "https", let host = url.host, !host.isEmpty else {
            fatalError("SUPABASE_URL must be a full https URL with a host. Got: \(value)")
        }

        return url
    }

    static var supabaseKey: String {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
              !raw.isEmpty
        else {
            fatalError("SUPABASE_KEY not found. Check Info.plist and Secrets.xcconfig.")
        }

        return raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}

let supabaseClient = SupabaseClient(
    supabaseURL: Secrets.supabaseURL,
    supabaseKey: Secrets.supabaseKey
)
