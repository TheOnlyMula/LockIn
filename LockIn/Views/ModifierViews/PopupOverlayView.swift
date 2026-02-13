//
//  PopupOverlayView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 18/1/2026.
//

import SwiftUI

struct PopupOverlay<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool

    let dimOpacity: Double
    let dismissOnTapOutside: Bool
    let popupMaxWidth: CGFloat
    let popupCornerRadius: CGFloat
    let popupShadowRadius: CGFloat
    let transition: AnyTransition
    let popupContent: () -> PopupContent

    init(
        isPresented: Binding<Bool>,
        dimOpacity: Double = 0.18,
        dismissOnTapOutside: Bool = true,
        popupMaxWidth: CGFloat = 320,
        popupCornerRadius: CGFloat = 18,
        popupShadowRadius: CGFloat = 18,
        transition: AnyTransition = .scale.combined(with: .opacity),
        @ViewBuilder popupContent: @escaping () -> PopupContent
    ) {
        self._isPresented = isPresented
        self.dimOpacity = dimOpacity
        self.dismissOnTapOutside = dismissOnTapOutside
        self.popupMaxWidth = popupMaxWidth
        self.popupCornerRadius = popupCornerRadius
        self.popupShadowRadius = popupShadowRadius
        self.transition = transition
        self.popupContent = popupContent
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        Color.black.opacity(dimOpacity)
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard dismissOnTapOutside else { return }
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isPresented = false
                                }
                            }

                        VStack {
                            popupContent()
                        }
                        .padding(18)
                        .frame(maxWidth: popupMaxWidth)
                        .background(
                            RoundedRectangle(cornerRadius: popupCornerRadius, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .shadow(radius: popupShadowRadius)
                        )
//                        .clipShape(RoundedRectangle(cornerRadius: popupCornerRadius, style: .continuous))
//                        .shadow(radius: popupShadowRadius)
//                        .transition(transition)
                    }
                }
            }
    }
}

extension View {
    func popupOverlay<PopupContent: View>(
        isPresented: Binding<Bool>,
        dimOpacity: Double = 0.18,
        dismissOnTapOutside: Bool = true,
        popupMaxWidth: CGFloat = 320,
        popupCornerRadius: CGFloat = 24,
        popupShadowRadius: CGFloat = 18,
        transition: AnyTransition = .scale.combined(with: .opacity),
        @ViewBuilder content: @escaping () -> PopupContent
    ) -> some View {
        modifier(
            PopupOverlay(
                isPresented: isPresented,
                dimOpacity: dimOpacity,
                dismissOnTapOutside: dismissOnTapOutside,
                popupMaxWidth: popupMaxWidth,
                popupCornerRadius: popupCornerRadius,
                popupShadowRadius: popupShadowRadius,
                transition: transition,
                popupContent: content
            )
        )
    }
}
