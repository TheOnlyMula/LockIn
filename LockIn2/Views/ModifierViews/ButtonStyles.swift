//
//  ButtonStyles.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 16/1/2026.
//
import SwiftUI

struct CapsuleIconButtonStyle: ButtonStyle {
    let tint: Color
    
    init(tint: Color = .blue) {
        self.tint = tint
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .foregroundStyle(.white)
            .background {
                Capsule(style: .continuous)
                    .fill(tint.gradient)
            }
    }
}

struct RectangleButtonStyle: ButtonStyle {
    let tint: Color
    
    init (tint: Color = .blue) {
        self.tint = tint
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(width: 300, height: 50)
            .background(Color.blue.gradient)
            .cornerRadius(10)
            .bold()
    }
}
