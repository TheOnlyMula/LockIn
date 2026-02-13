//
//  PillToggleView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 16/1/2026.
//
import SwiftUI

protocol CapsuleSegmentProtocol {
    var title: String { get }
    var symbolImage: String { get }
}

struct CapsuleSegmentedPicker<Selection: Hashable & CapsuleSegmentProtocol>: View {
    var config: CapsuleSegmentedPickerConfig
    private let segments: [Selection]
    @Binding private var selection: Selection

    // For sliding selection indicator
    @Namespace private var ns

    init(
        config: CapsuleSegmentedPickerConfig = .init(),
        segments: [Selection],
        selection: Binding<Selection>
    ) {
        self.config = config
        self.segments = segments
        self._selection = selection
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.self) { item in
                let isActive = selection == item

                HStack(spacing: 6) {
                    Image(systemName: item.symbolImage)
                        .font(.system(size: 14, weight: .semibold))

                    Text(item.title)
                }
                .font(config.font)
                .foregroundStyle(isActive ? config.activeTint : config.inactiveTint)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .background {
                    if isActive {
                        Capsule(style: .continuous)
                            .fill(config.activeBackgroundTint.gradient)
                            .matchedGeometryEffect(id: "ACTIVESEGMENT", in: ns)
                    }
                }
                .onTapGesture {
                    selection = item
                }
                .padding(.vertical, config.insetAmount)
            }
        }
        .padding(.horizontal, config.insetAmount)
        .frame(height: config.height)
        .background {
            ZStack {
                if config.isTransluscent {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                } else {
                    Rectangle()
                        .fill(config.backgroundColor)
                }
            }
        }
        .clipShape(.capsule(style: .continuous))
        .animation(config.segmentAnimation, value: selection)
    }
}

struct CapsuleSegmentedPickerConfig {
    var activeTint: Color = .white
    var activeBackgroundTint: Color = .blue
    var inactiveTint: Color = .gray

    var segmentAnimation: Animation = .smooth(duration: 0.35, extraBounce: 0)

    // Used only when `isTransluscent` is false
    var backgroundColor: Color = .gray.opacity(0.1)

    // Layout
    var height: CGFloat = 44
    var insetAmount: CGFloat = 6
    var isTransluscent: Bool = true
    
    // Typography
    var font: Font = .system(size: 14, weight: .semibold)
}

// MARK: - Example usage

enum ClockSection: String, CaseIterable, CapsuleSegmentProtocol {
    case timer, stopwatch

    var title: String {
        rawValue.capitalized
    }

    var symbolImage: String {
        switch self {
        case .timer: "deskclock"
        case .stopwatch: "stopwatch"
        }
    }
}

struct CapsuleSegmentedPickerDemo: View {
    @State private var section: ClockSection = .timer

    var body: some View {
        VStack(spacing: 20) {
            CapsuleSegmentedPicker(
                segments: ClockSection.allCases,
                selection: $section
            )
            .frame(maxWidth: 320)

            Text("Selected: \(section.rawValue)")
        }
        .padding()
    }
}

#Preview {
    CapsuleSegmentedPickerDemo()
}
