//
//  AppBackgroundModifier.swift
//  LockIn
//
//  Created by Multazim Mesbah on 14/1/2026.
//

import SwiftUI

struct AppBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("BOOL_BACKGROUNDPREFERENCE") var showWallpaper = false
    let isBlurred: Bool
    let blurRadius: CGFloat
    
    init(isBlurred: Bool = false, blurRadius: CGFloat = 5) {
        self.isBlurred = isBlurred
        self.blurRadius = blurRadius
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark
        ? Color(red: 65/255, green: 102/255, blue: 94/255)
        : Color(red: 255/255, green: 255/255, blue: 217/255)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if showWallpaper {
                Image(colorScheme == .dark ? "Dark Background" : "Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .scaleEffect(1.2)
                    .blur(radius: isBlurred ? blurRadius : 0)
            } else {
                backgroundColor
                    .ignoresSafeArea()
            }
            
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

extension View {
    func appBackground(blurred: Bool = false, blurRadius: CGFloat = 5) -> some View {
        modifier(AppBackgroundModifier(isBlurred: blurred, blurRadius: blurRadius))
    }
}

struct BackgroundCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(FocusSessionViewModel())
        .environmentObject(RelationshipViewModel())
}
