//
//  AddCategoryCardView.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 20/1/2026.
//
import SwiftUI

struct AddCategoryCardView: View {
    @Binding var newCategoryName: String
    @Binding var selectedIcon: String

    let iconOptions: [String]
    let maxCardWidth: CGFloat
    let onAdd: () -> Void

    @State private var addButtonPulse: Bool = false

    var body: some View {
        ZStack {
            BackgroundCard()

            VStack(alignment: .leading, spacing: 10) {
                Text("Add a category")
                    .font(.system(size: 24, weight: .bold))

                Text("Category Name")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                // Centered TextField
                HStack {
                    Spacer()

                    TextField("Add Text", text: $newCategoryName)
                        .disableAutocorrection(true)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .frame(maxWidth: maxCardWidth - 34)

                    Spacer()
                }

                Text("Select Icon")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(iconOptions, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            let isSelected = (selectedIcon == icon)

                            Image(systemName: icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isSelected ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(
                                            isSelected
                                            ? AnyShapeStyle(Color.blue.gradient)
                                            : AnyShapeStyle(.ultraThinMaterial)
                                        )
                                )
                                .animation(.easeInOut(duration: 0.15), value: selectedIcon)
                        }
                        .buttonStyle(.plain)
                    }
                }

                let isDisabled = newCategoryName
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty

                Button {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                        addButtonPulse = true
                    }

                    onAdd()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                            addButtonPulse = false
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text("Add Category")
                            .font(.system(size: 14, weight: .semibold))

                        Image(systemName: "plus.circle")
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                .scaleEffect(addButtonPulse ? 0.97 : 1.0)
                .opacity(isDisabled ? 0.25 : 1.0)
                .frame(maxWidth: maxCardWidth - 34)
                .buttonStyle(CapsuleIconButtonStyle())
                .disabled(isDisabled)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

#Preview {
    let preCategoryVM = CategoryViewModel()
    let preAuthVM = AuthViewModel()

    CategoryView()
        .environmentObject(preCategoryVM)
        .environmentObject(preAuthVM)
}
