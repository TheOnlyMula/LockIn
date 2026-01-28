//
//  FocusSessionViewModel.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 18/1/2026.
//
import Foundation

struct FocusSession: Codable, Identifiable {
    let id: Int
    let createdAt: Date
    let userID: UUID
    let duration: Int
    let category: String?
    let categoryIcon: String?
}

struct FocusSessionPayload: Encodable {
    let userID: UUID
    let duration: Int
    let category: String?
    let categoryIcon: String?
}

@MainActor
class FocusSessionViewModel: ObservableObject {
    @Published var focusSessions = [FocusSession]()
    
    func insertFocusSession(duration: Int, category: String, categoryIcon: String, userID: UUID) async throws {
        do {
            try await DatabaseManager.shared.insertFocusSession(
                duration: duration,
                category: category,
                categoryIcon: categoryIcon,
                userID: userID
            )
            focusSessions = try await DatabaseManager.shared.getFocusSession(for: userID)
        } catch {
            print("insertFocusSessions failed \(error.localizedDescription)")
        }
    }
    
    func getFocusSessions(userID: UUID) async throws {
        do {
            focusSessions = try await DatabaseManager.shared.getFocusSession(for: userID)
        } catch {
            print("getFocusSessions failed: \(error.localizedDescription)")
        }
    }
    
    func deleteFocusSession(focusSession: FocusSession) async throws {
        do {
            try await DatabaseManager.shared.deleteFocusSession(session: focusSession)
            focusSessions.removeAll { $0.id == focusSession.id }
        } catch {
            print("deleteFocusSession failed: \(error.localizedDescription)")
        }
    }
}
