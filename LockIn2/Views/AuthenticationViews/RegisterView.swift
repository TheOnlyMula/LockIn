//
//  RegisterView.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 24/1/2026.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let onLoginTap: () -> Void
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isRegisterPressed = false
    @State private var isLoginPressed = false

    var body: some View {
        GeometryReader { geo in
            let maxCardWidth = geo.size.width - 69
            
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 48, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    VStack {
                        Text("Register")
                            .font(.largeTitle)
                            .bold()
                        TextField("", text: $username, prompt: Text("Username").foregroundStyle(.gray))
                            .textFieldStyle()
                        TextField("", text: $email, prompt: Text("Email").foregroundStyle(.gray))
                            .textFieldStyle()
                        TextField("", text: $password, prompt: Text("Password").foregroundStyle(.gray))
                            .textFieldStyle()
                        TextField("", text: $confirmPassword, prompt: Text("Confirm Password").foregroundStyle(.gray))
                            .textFieldStyle()
                        Button {
                            Task {
                                await authViewModel.register(
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword
                                )
                            }
                        } label: {
                            HStack {
                                Text("Register")
                                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            }
                            .scaleEffect(isRegisterPressed ? 0.96 : 1)
                            .opacity(isRegisterPressed ? 0.85 : 1)
                        }
                        .buttonStyle(RectangleButtonStyle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    withAnimation(.easeOut(duration: 0.12)) {
                                        isRegisterPressed = true
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.12)) {
                                        isRegisterPressed = false
                                    }
                                }
                        )
                        Button {
                            onLoginTap()
                        } label: {
                            HStack {
                                Text("Already have an account? Log In")
                                Image(systemName: "rectangle.portrait.and.arrow.forward")
                            }
                            .scaleEffect(isLoginPressed ? 0.96 : 1)
                            .opacity(isLoginPressed ? 0.85 : 1)
                        }
                        .padding()
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    withAnimation(.easeOut(duration: 0.12)) {
                                        isLoginPressed = true
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.12)) {
                                        isLoginPressed = false
                                    }
                                }
                        )
                    }
                }
            }
            .frame(width: maxCardWidth, alignment: .top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
        .appBackground(blurred: true)
    }
}

#Preview {
    AuthView()
}
