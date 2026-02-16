//
//  AppWallpaper.swift
//  LockIn
//
//  Created by Multazim Mesbah on 14/1/2026.
//

import SwiftUI

struct AppWallpaper: ViewModifier {
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
        ? Color(.black)
        : Color(.white)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if showWallpaper {
                Image("drawnWallpaper")
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
        modifier(AppWallpaper(isBlurred: blurred, blurRadius: blurRadius))
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(FocusSessionViewModel())
        .environmentObject(RelationshipViewModel())
}
