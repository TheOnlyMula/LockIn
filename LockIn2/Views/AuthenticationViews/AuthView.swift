//
//  AuthView.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 24/1/2026.
//
import SwiftUI

enum AuthScreen {
    case login
    case register
}

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var screen: AuthScreen = .login
    
    var body: some View {
        ZStack {
            LoginView(
                onRegisterTap: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        screen = .register
                    }
                }
            )
            .opacity(screen == .login ? 1 : 0)
            .scaleEffect(screen == .login ? 1 : 0.97)
            //.compositingGroup()

            RegisterView(
                onLoginTap: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        screen = .login
                    }
                }
            )
            .opacity(screen == .register ? 1 : 0)
            .scaleEffect(screen == .register ? 1 : 0.97)
            //.compositingGroup()
        }
        .appBackground(blurred: true)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
