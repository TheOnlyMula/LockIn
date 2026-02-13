//
//  FocusSessionView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 15/1/2026.
//
import SwiftUI

struct FocusSessionRow: View {
    let session: FocusSession

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)

                Image(systemName: session.categoryIcon ?? "tag")
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(session.category ?? "Uncategorised")
                    .font(.system(size: 16, weight: .semibold))

                Text(formattedDate(session.createdAt))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(formatDuration(session.duration))
                .font(.system(size: 15, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}

struct FocusSessionView: View {
    @EnvironmentObject var focusSessionViewModel: FocusSessionViewModel
    
    @State private var showHint: Bool = false

    var body: some View {
        ZStack {
            BackgroundCard()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .padding(.horizontal, 10)
                .padding(.bottom, 75)
            
            VStack {
                HStack {
                    Text("Your Sessions")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 35)
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showHint.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 35)
                }
                
                if focusSessionViewModel.focusSessions.isEmpty {
                    ContentUnavailableView(
                        "No sessions made yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Create sessions to view them here")
                    )
                } else {
                    List {
                        ForEach(focusSessionViewModel.focusSessions) { focusSession in
                            FocusSessionRow(session: focusSession)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .listSectionSeparator(.hidden)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .padding() // match the inner padding visually inside the card
            .padding(.horizontal, 30)
            .padding(.bottom, 96)
        }
        .popupOverlay(isPresented: $showHint) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "list.bullet.below.rectangle")
                        .font(.system(size: 32))
                    Text("Sessions")
                        .font(.headline)
                        .font(.system(size: 32))
                }
                Text("""
                    This is a log of all your completed sessions.

                    Each entry shows the category you focused on, when the session happened, and how long you stayed locked in.

                    Use this view to reflect on your consistency and track where your time is really going.
                    """)
                    .font(.subheadline)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 320, alignment: .leading)
            }
        }
        .appBackground()
    }
    
    private func formatTimeToString(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    let vm = FocusSessionViewModel()
    vm.focusSessions = [
        FocusSession(
            id: 1,
            createdAt: Date().addingTimeInterval(-3600),
            userID: UUID(),
            duration: 1500,
            category: "Study",
            categoryIcon: "book"
        ),
        FocusSession(
            id: 2,
            createdAt: Date().addingTimeInterval(-7200),
            userID: UUID(),
            duration: 2700,
            category: "Gym",
            categoryIcon: "figure.run"
        ),
        FocusSession(
            id: 3,
            createdAt: Date().addingTimeInterval(-10800),
            userID: UUID(),
            duration: 3600,
            category: "Coding",
            categoryIcon: "laptopcomputer"
        )
    ]

    return FocusSessionView()
        .environmentObject(vm)
}
