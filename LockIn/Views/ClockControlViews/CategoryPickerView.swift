//
//  CategoryPickerView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 21/1/2026.
//
import SwiftUI

struct CategoryPickerView: View {
    @EnvironmentObject private var categoryViewModel: CategoryViewModel

    @Binding var selectedCategoryName: String?

    var isDisabled: Bool = false

    var enabledTint: Color = .white
    var disabledTint: Color = .gray

    var yOffset: CGFloat = 0
    var opacityWhenDisabled: Double = 0.6

    private var resolvedTint: Color { isDisabled ? disabledTint : enabledTint }

    var body: some View {
        let categories = categoryViewModel.categories
        let selectedCategory = selectedCategoryName.flatMap { name in
            categories.first(where: { $0.name == name })
        }

        return Picker(selection: $selectedCategoryName) {
            Text("Choose category").tag(String?.none)

            ForEach(categories, id: \.name) { cat in
                Label {
                    Text(cat.name)
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: cat.categoryIcon ?? "tag")
                        .foregroundStyle(.primary)
                }
                .tag(Optional(cat.name))
            }
        } label: {
            Group {
                if let cat = selectedCategory {
                    Label(cat.name, systemImage: cat.categoryIcon ?? "tag")
                } else {
                    Label("Choose a category", systemImage: "tag")
                }
            }
            .foregroundStyle(resolvedTint)
            .tint(resolvedTint)
        }
        .pickerStyle(.menu)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
        )
        .disabled(isDisabled)
        .opacity(isDisabled ? opacityWhenDisabled : 1)
        .offset(y: yOffset)
    }
}

#Preview {
    let prevCategoryVM = CategoryViewModel()
    
    prevCategoryVM.categories = [
        Category(userID: UUID(), name: "Study", categoryIcon: "book"),
        Category(userID: UUID(), name: "Gym", categoryIcon: "figure.run"),
        Category(userID: UUID(), name: "Programming", categoryIcon: "laptopcomputer")
    ]
    
    return ClockControlView()
        .environmentObject(prevCategoryVM)
        .environmentObject(FocusSessionViewModel())
}
