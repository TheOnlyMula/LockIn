//
//  LockIn2App.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 13/1/2026.
//

import SwiftUI

@main
struct LockIn2App: App {
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var focusSessionViewModel = FocusSessionViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainView()
                        .environmentObject(categoryViewModel)
                        .environmentObject(focusSessionViewModel)
                        .environmentObject(authViewModel)
                } else {
                    AuthView()
                        .environmentObject(authViewModel)
                }
            }
            .task {
                await authViewModel.getInitialSession()
            }
        }
    }
}
