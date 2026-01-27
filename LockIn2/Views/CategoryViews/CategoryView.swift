//
//  CategoryView.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 15/1/2026.
//
import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    @State private var newCategoryName: String = ""
    @State private var selectedIcon: String = "tag"
    
    private let iconOptions: [String] = [
        "tag", "book", "brain.head.profile", "figure.run", "figure.strengthtraining.traditional",
        "bolt", "laptopcomputer", "pencil", "music.note", "fork.knife", "leaf", "person.3.fill"
    ]
    
    var body: some View {
        GeometryReader { geo in
            let maxCardWidth = geo.size.width - 69
            
            VStack(spacing: 16) {
                
                // MARK: - "Categories" cardView
                CategoriesCardView(
                    title: "Your Categories",
                    maxCardWidth: maxCardWidth,
                    categories: categoryViewModel.categories
                ) { category in
                    Task {
                        await categoryViewModel.deleteCategory(category: category)
                    }
                }
                
                // MARK: - "Add Category" cardView
                AddCategoryCardView(
                    newCategoryName: $newCategoryName,
                    selectedIcon: $selectedIcon,
                    iconOptions: iconOptions,
                    maxCardWidth: maxCardWidth
                ) {
                    guard let userID = authViewModel.userID else { return }
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }

                    Task {
                        await categoryViewModel.insertCategory(
                            userID: userID,
                            text: trimmed,
                            categoryIcon: selectedIcon
                        )
                        newCategoryName = ""
                        selectedIcon = "tag"
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: maxCardWidth, alignment: .top)
            .frame(maxWidth: .infinity, maxHeight: geo.size.height - 100, alignment: .top)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .task {
            guard let userID = authViewModel.userID else { return }
            await categoryViewModel.getCategories(userID: userID)
        }
        .appBackground()
    }
}

#Preview {
    let prevCategoryVM = CategoryViewModel()
    let prevAuthVM = AuthViewModel()

    prevCategoryVM.categories = [
//        Category(
//            id: 1,
//            userID: UUID(),
//            text: "Deep Work",
//            categoryIcon: "brain.head.profile"
//        ),
//        Category(
//            id: 2,
//            userID: UUID(),
//            text: "Study",
//            categoryIcon: "book"
//        ),
//        Category(
//            id: 3,
//            userID: UUID(),
//            text: "Gym",
//            categoryIcon: "figure.strengthtraining.traditional"
//        )
    ]

    return CategoryView()
        .environmentObject(prevCategoryVM)
        .environmentObject(prevAuthVM)
}
