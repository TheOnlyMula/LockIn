//
//  CategoriesCard.swift
//  LockIn
//
//  Created by Multazim Mesbah on 20/1/2026.
//
import SwiftUI

struct CategoriesCardView: View {
    let title: String
    let maxCardWidth: CGFloat
    let categories: [Category]
    let onDelete: (Category) -> Void

    private let rowHeight: CGFloat = 44
    private let maxVisibleRows: CGFloat = 4.7

    private var listHeight: CGFloat {
        // Keep the card height stable: show up to `maxVisibleRows` rows, then scroll.
        let visibleRows = min(CGFloat(categories.count), maxVisibleRows)
        return CGFloat(visibleRows) * rowHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 24, weight: .bold))

            if categories.isEmpty {
                ContentUnavailableView(
                    "No categories made yet",
                    systemImage: "tag",
                    description: Text("Create categories to organise your sessions")
                )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)

                    List {
                        ForEach(categories, id: \.name) { category in
                            HStack(spacing: 12) {
                                Image(systemName: category.categoryIcon ?? "tag")
                                    .frame(width: 22)

                                Text(category.name)
                                    .font(.system(size: 16, weight: .semibold))

                                Spacer(minLength: 0)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    onDelete(category)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.top, 4)
                .frame(height: listHeight)
            }
        }
        .frame(maxWidth: maxCardWidth, alignment: .leading)
        .padding(16)
        .background(BackgroundCard())
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .fixedSize(horizontal: false, vertical: false)
    }
}
