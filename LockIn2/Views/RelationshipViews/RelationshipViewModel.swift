//
//  RelationshipViewModel.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 10/2/2026.
//

import Foundation

enum Status: String, Codable {
    case accepted
    case pending
    case blocked
}

struct Relationship: Codable, Identifiable {
    let requesterID: UUID
    let addresseeID: UUID
    let status: Status
    let createdAt: Date
    
    var id: String { "\(requesterID.uuidString) - \(addresseeID.uuidString)" }
}

struct RelationshipPayload: Encodable {
    let requesterID: UUID
    let addresseeID: UUID
}

enum RelationshipAction: String {
    case pending
    case accepted
    case blocked
    case delete
}

@MainActor
class RelationshipViewModel: ObservableObject {
    @Published var relationships: [Relationship] = []
    @Published var isLoading: Bool = false
    @Published var lastErrorMessage: String? = nil

    // Convenience filtered lists
    var accepted: [Relationship] { relationships.filter { $0.status == .accepted } }
    var pending: [Relationship] { relationships.filter { $0.status == .pending } }
    var blocked: [Relationship] { relationships.filter { $0.status == .blocked } }

    func getRelationships(userID: UUID) async {
        isLoading = true
        lastErrorMessage = nil
        defer { isLoading = false }

        do {
            relationships = try await DatabaseManager.shared.getRelationships(userID: userID)
        } catch {
            print("getRelationships failed: \(error)")
        }
    }
    
    // Inserts a relationship request. DB default status is 'pending'.
    // Optionally refreshes the relationship list afterwards.
    func insertRelationship(
        requesterID: UUID,
        addresseeID: UUID,
        refreshFor userIDToRefresh: UUID? = nil
    ) async {
        lastErrorMessage = nil

        do {
            try await DatabaseManager.shared.insertRelationship(requesterID: requesterID, addresseeID: addresseeID)
            if let userIDToRefresh {
                await getRelationships(userID: userIDToRefresh)
            }
        } catch {
            lastErrorMessage = "insertRelationship failed: \(error)"
            print(lastErrorMessage ?? "")
        }
    }

    // Updates a relationship between `userID` and `otherUserID`.
    // If `action == .delete`, the row is deleted.
    // Optionally refreshes the relationship list afterwards.
    func updateRelationship(
        userID: UUID,
        otherUserID: UUID,
        action: RelationshipAction,
        refresh: Bool = true
    ) async {
        lastErrorMessage = nil

        do {
            try await DatabaseManager.shared.updateRelationship(
                userID: userID,
                otherUserID: otherUserID,
                action: action.rawValue
            )

            if refresh {
                await getRelationships(userID: userID)
            }
        } catch {
            lastErrorMessage = "updateRelationship failed: \(error)"
            print(lastErrorMessage ?? "")
        }
    }

    // Convenience wrapper for deleting a relationship.
    func deleteRelationship(
        userID: UUID,
        otherUserID: UUID,
        refresh: Bool = true
    ) async {
        await updateRelationship(userID: userID, otherUserID: otherUserID, action: .delete, refresh: refresh)
    }
}
