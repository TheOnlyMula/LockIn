//
//  ColourAccents.swift
//  LockIn
//
//  Created by Multazim Mesbah on 17/2/2026.
//
import SwiftUI

enum AppColors {
    
    static let cardDark = Color(red: 53/255, green: 53/255, blue: 53/255)
    static let cardLight = Color(red: 125/255, green: 184/255, blue: 132/255)
    
    static func cardFill(colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? cardDark : cardLight
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(FocusSessionViewModel())
        .environmentObject(RelationshipViewModel())
}
