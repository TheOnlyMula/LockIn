//
//  ClockControlView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 14/1/2026.
//
import SwiftUI

enum ClockSelection: String, CaseIterable, CapsuleSegmentProtocol {
    case timer
    case stopwatch
    
    var title: String { rawValue.capitalized }
    
    var symbolImage: String {
        switch self {
        case .timer: "timer"
        case .stopwatch: "stopwatch"
        }
    }
    
    @ViewBuilder
    func contentView(lockSectionSwitch: Binding<Bool>) -> some View {
        switch self {
        case .timer:
            TimerControlView(lockSectionSwitch: lockSectionSwitch)
        case .stopwatch:
            StopwatchControlView(lockSectionSwitch: lockSectionSwitch)
        }
    }
    
    var hintTitle: String {
        switch self {
        case .timer: "How to use the Timer"
        case .stopwatch: "How to use the Stopwatch"
        }
    }
    
    var hintBody: String {
        switch self {
        case .timer:
            return """
            • Choose at least 10 minutes — meaningful focus starts with a real commitment.

            • Once you start, you have a 10‑second grace period to cancel if you change your mind.

            • After that, the session locks in so you can stay fully focused without second‑guessing.

            • While the timer is running, switching to the stopwatch is disabled to protect your flow.
            """
        case .stopwatch:
            return """
            • Hit Start and let the time run — momentum is the goal.

            • You get a 10‑second window to pause if you started by accident (you’ll see a countdown).

            • After 10 seconds, the stopwatch locks in: no pausing or stopping until you reach 10 minutes.

            • At 10 minutes, Finish becomes available so you can close the session intentionally.

            • While it’s running (after the first 10 seconds), switching back to the timer is locked to avoid accidental changes.
            """
        }
    }
}

struct ClockControlView: View {
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    
    @State private var section: ClockSelection = .timer
    @State private var isSectionSwitchLocked: Bool = false
    @State private var showHint: Bool = false
    
    private let cardSize = CGSize(
        width: 375,
        height: 550
    )
    
    var body: some View {
        ZStack {
            BackgroundCard() {
                VStack {
                    section.contentView(lockSectionSwitch: $isSectionSwitchLocked)
                        .frame(alignment: .center)
                }
            }
            .frame(height: cardSize.height)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showHint.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
            }
            
            .overlay(alignment: .top) {
                CapsuleSegmentedPicker(segments: ClockSelection.allCases, selection: $section)
                    .frame(width: (33 * cardSize.width / 35).rounded())
                    .padding(.top, 10)
                    .allowsHitTesting(!isSectionSwitchLocked)
                    .opacity(isSectionSwitchLocked ? 0.6 : 1.0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .popupOverlay(isPresented: $showHint) {
            VStack(spacing: 12) {
                Image(systemName: section.symbolImage)
                    .font(.system(size: 48))
                Text(section.hintTitle)
                    .font(.headline)
                Text(section.hintBody)
                    .font(.subheadline)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 320, alignment: .leading)
            }
        }
        .onChange(of: section) { _, _ in
            isSectionSwitchLocked = false
        }
        .appBackground()
    }
}

#Preview {
    MainView()
        .environmentObject(CategoryViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(FocusSessionViewModel())
        .environmentObject(RelationshipViewModel())
}
