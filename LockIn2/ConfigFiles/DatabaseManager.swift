//
//  DatabaseManager.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 27/12/2025.
//

//Task 1: Fatal error: SUPABASE_URL not found. Check Info.plist and Secrets.xcconfig.

import Foundation
import Supabase
import PostgREST

final class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}

    private enum Table {
        static let category = "Category"
        static let focusSession = "FocusSession"
        static let relationship = "Relationship"
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
                userID: userID,
                duration: duration,
                category: category,
                categoryIcon: categoryIcon
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
    
    // MARK: - Relationships

    /// Fetch all relationships where the user is either requester or addressee.
    /// Note: This returns *all* statuses. Filtering by status can be done in the caller.
    func getRelationships(userID: UUID) async throws -> [Relationship] {
        let response = try await supabaseClient
            .from(Table.relationship)
            .select("requesterID, addresseeID, status, createdAt")
            .or("requesterID.eq.\(userID.uuidString),addresseeID.eq.\(userID.uuidString)")
            .order("createdAt", ascending: false)
            .execute()

        return try Self.decoder.decode([Relationship].self, from: response.data)
    }

    /// Insert a relationship request (status defaults to 'pending' in DB).
    func insertRelationship(requesterID: UUID, addresseeID: UUID) async throws {
        let payload = RelationshipPayload(
            requesterID: requesterID,
            addresseeID: addresseeID
        )

        try await insert(into: Table.relationship, payload: payload)
    }

    /// Update a relationship between `userID` and `otherUserID`.
    /// - action: "pending" | "accepted" | "blocked" | "delete"
    ///
    /// The relationship row may have the active user in either requesterID or addresseeID,
    /// so this function attempts both orientations.
    func updateRelationship(
        userID: UUID,
        otherUserID: UUID,
        action: String
    ) async throws {
        let normalized = action.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if normalized == "delete" {
            // Try delete in both orientations (user as requester, then user as addressee)
            let deleted = try await deleteRelationshipIfExists(requesterID: userID, addresseeID: otherUserID)
            if !deleted {
                _ = try await deleteRelationshipIfExists(requesterID: otherUserID, addresseeID: userID)
            }
            return
        }

        guard normalized == "pending" || normalized == "accepted" || normalized == "blocked" else {
            throw NSError(
                domain: "DatabaseManager.Relationship",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid relationship action/status: \(action)"]
            )
        }

        // Try update in both orientations (user as requester, then user as addressee)
        let updated = try await updateRelationshipStatusIfExists(
            requesterID: userID,
            addresseeID: otherUserID,
            status: normalized
        )

        if !updated {
            _ = try await updateRelationshipStatusIfExists(
                requesterID: otherUserID,
                addresseeID: userID,
                status: normalized
            )
        }
    }

    // MARK: - Relationship helpers

    /// Returns true if a row was updated.
    private func updateRelationshipStatusIfExists(
        requesterID: UUID,
        addresseeID: UUID,
        status: String
    ) async throws -> Bool {
        let response = try await supabaseClient
            .from(Table.relationship)
            .update(["status": status])
            .eq("requesterID", value: requesterID)
            .eq("addresseeID", value: addresseeID)
            .select("requesterID, addresseeID, status, createdAt")
            .execute()

        // If no rows matched, PostgREST returns an empty array for a .select() on update.
        let updatedRows = try Self.decoder.decode([Relationship].self, from: response.data)
        return !updatedRows.isEmpty
    }

    /// Returns true if a row was deleted.
    private func deleteRelationshipIfExists(
        requesterID: UUID,
        addresseeID: UUID
    ) async throws -> Bool {
        let response = try await supabaseClient
            .from(Table.relationship)
            .delete()
            .eq("requesterID", value: requesterID)
            .eq("addresseeID", value: addresseeID)
            .select("requesterID, addresseeID, status, createdAt")
            .execute()

        let deletedRows = try Self.decoder.decode([Relationship].self, from: response.data)
        return !deletedRows.isEmpty
    }

}
