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
        
    }
    
    func getFocusSessions(userID: UUID) async throws {
        
    }
    
    func deleteFocusSession(focusSession: FocusSession) async throws {
        
    }
}
