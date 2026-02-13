//
//  LockInApp.swift
//  LockIn
//
//  Created by Multazim Mesbah on 13/1/2026.
//

import SwiftUI

@main
struct LockInApp: App {
    @StateObject private var categoryViewModel = CategoryViewModel()
    @StateObject private var focusSessionViewModel = FocusSessionViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var relationshipViewModel = RelationshipViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainView()
                        .environmentObject(categoryViewModel)
                        .environmentObject(focusSessionViewModel)
                        .environmentObject(authViewModel)
                        .environmentObject(relationshipViewModel)
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
