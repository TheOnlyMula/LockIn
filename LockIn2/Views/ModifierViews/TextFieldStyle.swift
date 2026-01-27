//
//  TextFieldStyle.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 24/1/2026.
//
import SwiftUI

struct TextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(.black)
            .frame(width: 300, height: 50)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
}

extension View {
    func textFieldStyle() -> some View {
        self.modifier(TextFieldStyle())
    }
}
