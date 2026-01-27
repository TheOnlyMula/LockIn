//
//  DatabaseManager.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 27/12/2025.
//
import Foundation
import Supabase
import PostgREST

final class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}

    private enum Table {
        static let category = "Category"
        static let focusSession = "FocusSession"
        static let extraUserData = "Relationship"

    }

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase

        // Postgres timestamptz is returned as ISO-8601.
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)

            if let date = iso.date(from: str) {
                return date
            }

            // Fallback without fractional seconds
            let isoNoFrac = ISO8601DateFormatter()
            isoNoFrac.formatOptions = [.withInternetDateTime]
            if let date = isoNoFrac.date(from: str) {
                return date
            }
            //throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO-8601 date: \(str)")

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO-8601 date: \(str)"
            )
        }
        return d
    }()

    // MARK: - Core Helpers

    private func fetchList<T: Decodable>(
        from table: String,
        select columns: String,
        userID: UUID? = nil,
        orderBy: (column: String, ascending: Bool)? = nil
    ) async throws -> [T] {
        let selected = supabaseClient
            .from(table)
            .select(columns)

        var filtered = selected

        if let userID {
            filtered = filtered.eq("userID", value: userID)
        }

        let response = try await filtered.execute()
        return try Self.decoder.decode([T].self, from: response.data)
    }

    private func insert<T: Encodable>(
        into table: String,
        payload: T
    ) async throws {
        _ = try await supabaseClient
            .from(table)
            .insert(payload)
            .execute()
    }

    private func delete(
        from table: String,
        equals filters: [(String, any PostgrestFilterValue)]
    ) async throws {
        var query = supabaseClient
            .from(table)
            .delete()

        for (column, value) in filters {
            query = query.eq(column, value: value)
        }

        _ = try await query.execute()
    }

    // MARK: - FocusSessions

    func getFocusSession(for userID: UUID) async throws -> [FocusSession] {
            try await fetchList(
                from: Table.focusSession,
                select: "id, createdAt, duration, category, categoryIcon, userID",
                userID: userID,
                orderBy: ("createdAt", false)
            )
        }

        func insertFocusSession(
            duration: Int,
            category: String,
            categoryIcon: String,
            userID: UUID
        ) async throws {

            let payload = FocusSessionPayload(
                duration: duration,
                category: category,
                categoryIcon: categoryIcon,
                userID: userID
            )

            try await insert(into: Table.focusSession, payload: payload)
        }

    func deleteFocusSession(session: FocusSession) async throws {
        try await delete(
            from: Table.focusSession,
            equals: [
                ("id", session.id),
                ("userID", session.userID)
            ]
        )
    }

    // MARK: - Categories

    func getCategories(for userID: UUID) async throws -> [Category] {
        try await fetchList(
            from: Table.category,
            select: "userID, name, categoryIcon",
            userID: userID,
            orderBy: ("name", true)

        )
    }

    func insertCategory(
        userID: UUID,
        text: String,
        categoryIcon: String?
    ) async throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Send keys that match the DB schema: userID, name, categoryIcon
        struct CategoryInsertPayload: Encodable {
            let userID: UUID
            let name: String
            let categoryIcon: String?
        }

        let payload = CategoryInsertPayload(userID: userID, name: trimmed, categoryIcon: categoryIcon)

        try await insert(into: Table.category, payload: payload)
    }

    func deleteCategory(category: Category) async throws {
        try await delete(
            from: Table.category,
            equals: [
                ("userID", category.userID),
                ("name", category.name)
            ]
        )
    }
}
