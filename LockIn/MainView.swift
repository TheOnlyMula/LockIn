//
//  MainView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 15/1/2026.
//

import SwiftUI

enum AppTab: String, CaseIterable, FloatingTabProtocol {
    case friends = "Friends"
    case sessions = "Sessions"
    case clock = "Timer"
    case categories = "Categories"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .clock: "deskclock"
        case .friends: "person.3.fill"
        case .categories: "tag"
        case .sessions: "list.bullet.rectangle.portrait"
        case .settings: "gear"
        }
    }
}

struct MainView: View {
    @State private var activeTab: AppTab = .clock
    var body: some View {

        FloatingTabView(selection: $activeTab) { tab, tabBarHeight in
            switch tab {
            case .clock: ClockControlView()
            case .friends: RelationshipView()
            case .categories: CategoryView()
            case .sessions: FocusSessionView()
            case .settings: SettingsView() 
            }
        }
        
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(FocusSessionViewModel())
        .environmentObject(RelationshipViewModel())
}
