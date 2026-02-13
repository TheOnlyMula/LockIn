//
//  StopwatchControlView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 14/1/2026.
//
import SwiftUI

private struct DialConfig {
    let maximumValue: CGFloat      // used for tint scaling
    let totalValue: CGFloat        // used for ring wrapping
    let radius: CGFloat
}

struct StopwatchControlView: View {
    @Binding var lockSectionSwitch: Bool
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var focusSessionViewModel: FocusSessionViewModel
    
    init(lockSectionSwitch: Binding<Bool> = .constant(false)) {
        self._lockSectionSwitch = lockSectionSwitch
    }

    @State private var isRunning: Bool = false
    @State private var selectedCategoryName: String? = nil
    @State private var didLogCompletedSession: Bool = false

    // Stopwatch state
    // what UI displays (seconds)
    @State private var elapsedValue: CGFloat = 0.0

    // Accurate elapsed tracking (works across background)
    @State private var totalAccumulatedTime: TimeInterval = 0
    @State private var lastDateObserved: Date? = nil

    private let stopLockoutSeconds: TimeInterval = 10
    private let minFinishSeconds: TimeInterval = 10 * 60

    private var canStopOrPauseNow: Bool {
        totalAccumulatedTime <= stopLockoutSeconds
    }

    private var canFinishNow: Bool {
        totalAccumulatedTime >= minFinishSeconds
    }

    private var resolvedCategoryForSaving: (name: String, icon: String) {
        guard let name = selectedCategoryName,
              let cat = categoryViewModel.categories.first(where: { $0.name == name })
        else {
            return (name: "Uncategorised", icon: "tag")
        }
        return (name: cat.name, icon: cat.categoryIcon ?? "tag")
    }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 350, height: 200)

                VStack(spacing: 16) {
                    
                    CategoryPickerView(
                        selectedCategoryName: $selectedCategoryName,
                        isDisabled: isRunning,
                        enabledTint: .white,
                        disabledTint: .gray,
                        yOffset: 10
                    )
                    
                    Text(formatTimeToString(elapsedValue))
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .bold()

                    controlsRow
                }
                .frame(width: 350, height: 200)
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .animation(.linear(duration: 0.1), value: elapsedValue)
            .frame(width: 350, height: 350)
        }
        .onReceive(timer) { _ in
            updateTiming(now: Date())
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard isRunning else { return }
            switch newPhase {
            case .active, .inactive, .background:
                updateTiming(now: Date())
            @unknown default:
                break
            }
        }
    }

    @ViewBuilder
    private var controlsRow: some View {
        HStack(spacing: 12) {
            if !isRunning {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRunning = true
                        lastDateObserved = Date()
                        didLogCompletedSession = false
                        lockSectionSwitch = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                        Text(elapsedValue == 0 ? "Start" : "Resume")
                    }
                }
                .buttonStyle(CapsuleIconButtonStyle())

                // Reset only when stopped and non-zero
                if elapsedValue > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            resetStopwatch()
                            lockSectionSwitch = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                    }
                    .buttonStyle(CapsuleIconButtonStyle(tint: .gray))
                }
            } else {
                if canStopOrPauseNow {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            // pause (allowed only in first 10 seconds)
                            updateTiming(now: Date())
                            isRunning = false
                            lastDateObserved = nil
                            didLogCompletedSession = false
                            lockSectionSwitch = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pause.fill")
                            Text("Pause (\(max(0, Int(stopLockoutSeconds - totalAccumulatedTime))))")
                        }
                    }
                    .buttonStyle(CapsuleIconButtonStyle(tint: .red))
                } else if canFinishNow {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            // finish (allowed only after 10 minutes)
                            updateTiming(now: Date())

                            if !didLogCompletedSession {
                                didLogCompletedSession = true

                                let resolved = resolvedCategoryForSaving
                                let durationSeconds = Int(totalAccumulatedTime.rounded(.down))

                                Task {
                                    do {
                                        try await focusSessionViewModel.insertFocusSession(
                                            duration: durationSeconds,
                                            category: resolved.name,
                                            categoryIcon: resolved.icon,
                                            userID: authViewModel.userID!
                                        )
                                    } catch {
                                        print("Failed to insert focus session: \(error.localizedDescription)")
                                    }
                                }
                            }

                            isRunning = false
                            lastDateObserved = nil
                            lockSectionSwitch = false
                            didLogCompletedSession = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Finish")
                        }
                    }
                    .buttonStyle(CapsuleIconButtonStyle(tint: .green))
                } else {
                    // Locked window: cannot stop between 10s and 10min
                    Text("Locked • \(formatTimeToString(CGFloat(max(0, minFinishSeconds - totalAccumulatedTime))))")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Capsule(style: .continuous).fill(.ultraThickMaterial))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func updateTiming(now: Date) {
        guard isRunning else { return }

        if lastDateObserved == nil { lastDateObserved = now }

        let delta = now.timeIntervalSince(lastDateObserved ?? now)
        if delta > 0 { totalAccumulatedTime += delta }
        lastDateObserved = now

        elapsedValue = CGFloat(totalAccumulatedTime)
        // Lock section switching only after 10 seconds while running
        lockSectionSwitch = isRunning && totalAccumulatedTime > stopLockoutSeconds
    }

    private func resetStopwatch() {
        isRunning = false
        lockSectionSwitch = false
        totalAccumulatedTime = 0
        lastDateObserved = nil
        elapsedValue = 0
        didLogCompletedSession = false
    }

    private func formatTimeToString(_ x: CGFloat) -> String {
        let totalSeconds = max(0, Int(x.rounded(.down)))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if totalSeconds == 0 { return "0:00" }
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    let prevCategoryVM = CategoryViewModel()
    
    prevCategoryVM.categories = [
        Category(userID: UUID(), name: "Study", categoryIcon: "book"),
        Category(userID: UUID(), name: "Gym", categoryIcon: "figure.run"),
        Category(userID: UUID(), name: "Programming", categoryIcon: "laptopcomputer")
    ]
    
    return ClockControlView()
        .environmentObject(prevCategoryVM)
}
