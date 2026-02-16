//
//  FloatingTabView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 15/1/2026.
//
import SwiftUI

protocol FloatingTabProtocol {
    var symbolImage: String { get }
}

struct FloatingTabView<Content: View, Value: CaseIterable & Hashable & FloatingTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    var config: FloatingTabConfig
    @Binding var selection: Value
    var content: (Value, CGFloat) -> Content
    
    init(config: FloatingTabConfig = .init(), selection: Binding<Value>, @ViewBuilder content: @escaping (Value, CGFloat) -> Content) {
        self.config = config
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if #available(iOS 18, *) {
                // New Tab View
                TabView(selection: $selection) {
                    ForEach(Value.allCases, id: \.hashValue) { tab in
                        Tab.init(value: tab) {
                            content(tab, 0)
                                .toolbarVisibility(.hidden, for: .tabBar)
                        }
                    }
                }
            } else {
                // Old Tab View
                TabView(selection: $selection) {
                    ForEach(Value.allCases, id: \.hashValue) { tab in
                        content(tab, 0)
                            .tag(tab)
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            
            FloatingTabBar(config: config, activeTab: $selection)
                .padding(.horizontal, config.hPadding)
                .padding(.bottom, config.bPadding)
        }
    }
}

struct FloatingTabConfig {
    var activeTint: Color = .white
    var activeBackgroundTint: Color = .blue
    var inactiveTint: Color = .gray
    var tabAnimation: Animation = .smooth(duration: 0.35, extraBounce: 0)
    var backgroundColor: Color = .gray.opacity(0.1)
    var insetAmount: CGFloat = 6
    var hPadding: CGFloat = 15
    var bPadding: CGFloat = 5
}

fileprivate struct FloatingTabBar<Value: CaseIterable & Hashable & FloatingTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    var config: FloatingTabConfig
    @Binding var activeTab: Value
    // For Tab Sliding Effect
    @Namespace private var animation
    @State private var toggleSymbolEffect: [Bool] = Array(repeating: false, count: Value.allCases.count)
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("BOOL_BACKGROUNDPREFERENCE") var showWallpaper = false
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Value.allCases, id: \.hashValue) { tab in
                let isActive = activeTab == tab
                let index = (Value.allCases.firstIndex(of: tab) as? Int) ?? 0
                
                Image(systemName: tab.symbolImage)
                    .font(.title3)
                    .foregroundStyle(isActive ? config.activeTint : config.inactiveTint)
                    .symbolEffect(.bounce.byLayer.down, value: toggleSymbolEffect[index])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .background {
                        if isActive  {
                            Capsule(style: .continuous)
                                .fill(config.activeBackgroundTint.gradient)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .onTapGesture {
                        activeTab = tab
                        toggleSymbolEffect[index].toggle()
                    }
                    .padding(.vertical, config.insetAmount)
            }
        }
        .padding(.horizontal, config.insetAmount)
        .frame(height: 50)
        .background {
            ZStack {
                if showWallpaper {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                } else {
                    Rectangle()
                        .fill(AppColors.cardFill(colorScheme: colorScheme))
                }
            }
        }
        .clipShape(.capsule(style: .continuous))
        .animation(config.tabAnimation, value: activeTab)
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(FocusSessionViewModel())
        .environmentObject(RelationshipViewModel())
}
