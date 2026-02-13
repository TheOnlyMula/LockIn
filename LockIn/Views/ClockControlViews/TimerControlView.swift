//
//  TimerControlView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 14/1/2026.
//
import SwiftUI

private struct DialConfig {
    let minimumValue: CGFloat
    let maximumValue: CGFloat
    let totalValue: CGFloat
    let knobRadius: CGFloat
    let radius: CGFloat
    let stepValue: CGFloat
}

struct TimerControlView: View {
    @Binding var lockSectionSwitch: Bool
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var focusSessionViewModel: FocusSessionViewModel
    
    init(lockSectionSwitch: Binding<Bool> = .constant(false)) {
        self._lockSectionSwitch = lockSectionSwitch
    }

    @State private var isRunning: Bool = false
    //@State private var showStopButton: Bool = false

    // Dial state (selection)
    @State private var timeValue: CGFloat = 0.0
    @State private var angleValue: CGFloat = 0.0

    // Countdown state
    @State private var countDownValue: CGFloat = 0.0
    @State private var startValue: CGFloat = 0.0

    // Accurate elapsed tracking (works across background)
    @State private var totalAccumulatedTime: TimeInterval = 0
    @State private var lastDateObserved: Date? = nil
    @State private var didLogCompletedSession: Bool = false

    // Category selection
    @State private var selectedCategoryName: String? = nil

    private var selectedCategoryLabel: String {
        guard let name = selectedCategoryName,
              let cat = categoryViewModel.categories.first(where: { $0.name == name })
        else {
            return "Choose category"
        }
        return cat.name
    }
    private var resolvedCategoryForSaving: (name: String, icon: String) {
        guard let name = selectedCategoryName,
              let cat = categoryViewModel.categories.first(where: { $0.name == name })
        else {
            return (name: "Uncategorised", icon: "tag")
        }
        return (name: cat.name, icon: cat.categoryIcon ?? "tag")
    }

    private let config = DialConfig(
        minimumValue: 0.0,
        maximumValue: 7200.0,
        totalValue: 7200.0,
        knobRadius: 14.0,
        radius: 150.0,
        stepValue: 60.0
    )

    // UI should show the selected time when idle, remaining time when running
    private var displayValue: CGFloat {
        isRunning ? countDownValue : timeValue
    }

    // 0.0 = blue (min) -> 1.0 = red (max)
    private var dialProgress01: CGFloat {
        guard config.maximumValue > 0 else { return 0 }
        return min(max(displayValue / config.maximumValue, 0), 1)
    }

    private var dialTint: Color {
        // Interpolate between system blue and system green
        if timeValue < 600 {
            return Color(.red)
        }
        
        let start = UIColor.systemBlue
        let end = UIColor.systemGreen

        var sr: CGFloat = 0, sg: CGFloat = 0, sb: CGFloat = 0, sa: CGFloat = 0
        var er: CGFloat = 0, eg: CGFloat = 0, eb: CGFloat = 0, ea: CGFloat = 0
        start.getRed(&sr, green: &sg, blue: &sb, alpha: &sa)
        end.getRed(&er, green: &eg, blue: &eb, alpha: &ea)

        let t = dialProgress01
        let r = sr + (er - sr) * t
        let g = sg + (eg - sg) * t
        let b = sb + (eb - sb) * t
        let a = sa + (ea - sa) * t

        return Color(.sRGB, red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ZStack {
                // background circle
                Circle()
                    .fill(.ultraThinMaterial)

                // clock notches
                ForEach(0..<60, id: \.self) { i in
                    Rectangle()
                        .fill(.white)
                        .frame(width: 2.5, height: (i % 5) == 0 ? 15 : 5)
                        .offset(y: (300) / 2)
                        .rotationEffect(.init(degrees: Double(i) * 6))
                }

                // progress-bar circle
                Circle()
                    .trim(from: 0.0, to: displayValue / config.totalValue)
                    .stroke(dialTint, lineWidth: 5)
                    .frame(width: config.radius * 2, height: config.radius * 2)
                    .rotationEffect(.degrees(-90))

                // Knob
                Circle()
                    .fill(dialTint)
                    .frame(width: config.knobRadius * 2, height: config.knobRadius * 2)
                    .offset(y: -config.radius)
                    .rotationEffect(.degrees(Double(angleValue)))
                    .allowsHitTesting(false)

                // Drag surface (so dragging anywhere on the dial moves the knob)
                Circle()
                    .fill(Color.clear)
                    .contentShape(Circle())
                    .frame(width: config.radius * 2, height: config.radius * 2)
                    .allowsHitTesting(!isRunning)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                change(location: value.location, in: CGSize(width: config.radius * 2, height: config.radius * 2))
                            }
                    )

                // Timer text
                ZStack {
                    Text(formatTimeToString(displayValue))
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .bold()
                    
                    CategoryPickerView(
                        selectedCategoryName: $selectedCategoryName,
                        isDisabled: isRunning,
                        enabledTint: .white,
                        disabledTint: .gray,
                        yOffset: -65
                    )
                }

                if !isRunning {
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            guard timeValue >= 600 else { return } // require >= 10 minutes

                            // Allow switching initially; lock will engage after 10s
                            lockSectionSwitch = false

                            startValue = timeValue
                            countDownValue = timeValue

                            totalAccumulatedTime = 0
                            lastDateObserved = Date()
                            didLogCompletedSession = false
                            angleValue = (timeValue / config.totalValue) * 360
                            isRunning = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                            Text(timeValue < 600 ? "Minimum 10 min" : "Start Timer")
                        }
                    }
                    .buttonStyle(CapsuleIconButtonStyle())
                    .disabled(timeValue < 600)
                    .opacity(timeValue < 600 ? 0.5 : 1)
                    .offset(y: 70)
                } else if totalAccumulatedTime <= 10 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isRunning = false
                            lockSectionSwitch = false
                            countDownValue = 0

                            totalAccumulatedTime = 0
                            lastDateObserved = nil
                            didLogCompletedSession = false
                            timeValue = startValue
                            angleValue = (timeValue / config.totalValue) * 360
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "stop.circle")
                            Text("Stop (\(Int(10 - totalAccumulatedTime)))")
                        }
                    }
                    .buttonStyle(CapsuleIconButtonStyle(tint: .red))
                    .offset(y: 70)
                }
            }
            .animation(.linear(duration: 0.1), value: displayValue)
            .frame(width: config.radius * 2 + 50, height: config.radius * 2 + 50)
        }
        .onReceive(timer) { _ in
            updateTiming(now: Date())
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard isRunning else { return }

            switch newPhase {
            case .active:
                // App became active again; immediately account for time spent away
                updateTiming(now: Date())
            case .inactive, .background:
                // App is leaving the foreground; capture elapsed up to this moment
                updateTiming(now: Date())
            @unknown default:
                break
            }
        }
    }

    private func formatTimeToString(_ x: CGFloat) -> String {
        let totalSeconds = max(0, Int(x.rounded(.down)))

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if totalSeconds == 0 {
            return "0:00"
        }

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    private func updateTiming(now: Date) {
        guard isRunning else { return }

        if lastDateObserved == nil {
            lastDateObserved = now
        }

        let delta = now.timeIntervalSince(lastDateObserved ?? now)
        if delta > 0 {
            totalAccumulatedTime += delta
        }
        lastDateObserved = now

        // Lock section switching after 10 seconds while running
        lockSectionSwitch = isRunning && totalAccumulatedTime > 10

        let remaining = max(0, TimeInterval(startValue) - totalAccumulatedTime)

        // Update UI state from remaining time
        countDownValue = CGFloat(remaining)
        timeValue = countDownValue
        angleValue = (timeValue / config.totalValue) * 360

        if remaining <= 0 {
            if !didLogCompletedSession {
                didLogCompletedSession = true

                let resolved = resolvedCategoryForSaving
                let durationSeconds = Int(startValue)

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
            // End of countdown
            isRunning = false
            lockSectionSwitch = false
            countDownValue = 0
            timeValue = 0
            angleValue = 0
            lastDateObserved = nil
            didLogCompletedSession = false
        }
    }

    private func change(location: CGPoint, in size: CGSize) {
        // Convert touch location into vector from center
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y

        // Angle: 0 at top, clockwise increasing
        let angle = atan2(dy, dx) + (.pi / 2.0)
        let fixedAngle = angle < 0 ? angle + 2.0 * .pi : angle

        // Convert angle to raw value
        let rawValue = fixedAngle / (2.0 * .pi) * config.totalValue

        // Snap to step (e.g., 60s)
        let step = config.stepValue
        let snappedValue = round(rawValue / step) * step

        // Clamp
        let clamped = min(max(snappedValue, config.minimumValue), config.maximumValue)

        timeValue = clamped
        angleValue = (clamped / config.totalValue) * 360
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
