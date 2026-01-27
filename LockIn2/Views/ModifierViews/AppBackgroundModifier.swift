//
//  AppBackgroundModifier.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 14/1/2026.
//

import SwiftUI

struct AppBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let isBlurred: Bool
    let blurRadius: CGFloat
    
    init(isBlurred: Bool = false, blurRadius: CGFloat = 5) {
        self.isBlurred = isBlurred
        self.blurRadius = blurRadius
    }
    
    func body(content: Content) -> some View {
        ZStack {
            Image(colorScheme == .dark ? "Dark Background" : "Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .scaleEffect(1.2)
                .blur(radius: isBlurred ? blurRadius : 0)
            
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
    //var cornerRadius: CGFloat = 24
    
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.ultraThinMaterial)
    }
}

#Preview {
    MainView()
}
