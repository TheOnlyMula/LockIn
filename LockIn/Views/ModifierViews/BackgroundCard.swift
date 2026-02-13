//
//  BackgroundCard.swift
//  LockIn
//
//  Created by Multazim Mesbah on 13/2/2026.
//
import SwiftUI

private struct BackgroundCardAvailableWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = UIScreen.main.bounds.width

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next > 0 { value = next }
    }
}

struct BackgroundCard<Content: View>: View {

    // Width of the card as a fraction of the available width (typically the screen or parent container).
    // Example: 0.92 means 92% of the available width.
    let widthFraction: CGFloat
    private let content: Content

    @State private var availableWidth: CGFloat = UIScreen.main.bounds.width
    @AppStorage("BOOL_BACKGROUNDPREFERENCE") var showWallpaper = false

    init(
        //adjust width of cards
        widthFraction: CGFloat = 0.94,
        @ViewBuilder content: () -> Content
    ) {
        self.widthFraction = min(max(widthFraction, 0.1), 1.0)
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)

            content
        }
        .frame(width: availableWidth * widthFraction)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: BackgroundCardAvailableWidthKey.self, value: proxy.size.width)
            }
        )
        .onPreferenceChange(BackgroundCardAvailableWidthKey.self) { w in
            guard w > 0 else { return }
            // Avoid tiny oscillations.
            if abs(availableWidth - w) > 0.5 {
                availableWidth = w
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(FocusSessionViewModel())
        .environmentObject(RelationshipViewModel())
}
