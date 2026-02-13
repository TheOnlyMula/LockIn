//
//  CategoryViewModel.swift
//  LockIn
//
//  Created by Multazim Mesbah on 18/1/2026.
//
import Foundation

struct Category: Codable, Identifiable {
    let userID: UUID
    let name: String
    let categoryIcon: String?
    
    var id: String { "\(userID.uuidString)-\(name)" }
}

struct CategoryPayload: Encodable {
    let userID: UUID
    let text: String
    let categoryIcon: String?
}

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories = [Category]()
    
    func insertCategory(userID: UUID, text: String, categoryIcon: String? = nil) async {
        do {
            try await DatabaseManager.shared.insertCategory(userID: userID, text: text, categoryIcon: categoryIcon)
            // Refresh after insert (simple + correct)
            categories = try await DatabaseManager.shared.getCategories(for: userID)
        } catch {
            print("insertCategory failed: \(error)")
        }
    }
    
    func getCategories(userID: UUID) async {
        do {
            categories = try await DatabaseManager.shared.getCategories(for: userID)
        } catch {
            print("getCategories failed: \(error)")
        }
    }
    
    func deleteCategory(category: Category) async {
        do {
            try await DatabaseManager.shared.deleteCategory(category: category)
            categories.removeAll { $0.id == category.id }
        } catch {
            print("deleteCategory failed: \(error)")
        }
    }
}
