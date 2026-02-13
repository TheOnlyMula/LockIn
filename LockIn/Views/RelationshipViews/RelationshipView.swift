//
//  RelationshipView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 15/1/2026.
//

/*swift
@Environment(\.presentToast) var presentToast

Button("Show Toast") {
  let toast = ToastValue(
    icon: Image(systemName: "bell"),
    message: "You have a new notification."
  )
  presentToast(toast)
}
*/

import SwiftUI
import Toasts

struct RelationshipView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var relationshipViewModel: RelationshipViewModel
    @Environment(\.presentToast) private var presentToast
    
    @State private var newFriendUUIDString: String = ""
    @GestureState private var isPressingCopyButton: Bool = false

    private struct RelationshipRow: View {
        let relationship: Relationship
        let activeUserID: UUID?

        private var otherUserID: UUID {
            guard let activeUserID else {
                // Fallback; in practice activeUserID should exist when showing this list.
                return relationship.addresseeID
            }
            return relationship.requesterID == activeUserID ? relationship.addresseeID : relationship.requesterID
        }

        var body: some View {
            HStack(spacing: 14) {

                VStack(alignment: .leading, spacing: 4) {
                    Text(shortUUID(otherUserID))
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)

                    Text(relationship.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(relationship.status.rawValue.capitalized)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }

        private func shortUUID(_ uuid: UUID) -> String {
            let s = uuid.uuidString
            // e.g. ABCDEF12…7890
            let prefix = s.prefix(8)
            let suffix = s.suffix(4)
            return "\(prefix)…\(suffix)"
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                ZStack {
                    BackgroundCard()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VStack (alignment: .leading, spacing: 10){
                        
                        Text("Your Friends")
                            .font(.system(size: 24, weight: .bold))
                            .padding(24)
                        
                        if relationshipViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal, 24)
                        } else if relationshipViewModel.relationships.isEmpty {
                            ContentUnavailableView(
                                "No friends made yet",
                                systemImage: "person.3.fill",
                                description: Text("Enter your UUID to add a friend")
                            )
                            .padding(.horizontal, 24)
                        } else {
                            List {
                                ForEach(relationshipViewModel.relationships) { relationship in
                                    RelationshipRow(
                                        relationship: relationship,
                                        activeUserID: authViewModel.userID
                                    )
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
                            .padding(.horizontal, 24)
                        }

                        Spacer()
                        
                        HStack {
                            Spacer()

                            Button {
                                guard let activeUserID = authViewModel.userID else { return }
                                UIPasteboard.general.string = activeUserID.uuidString
                            } label: {
                                HStack(spacing: 10) {
                                    Text("Copy your UUID")
                                        .font(.system(size: 14, weight: .semibold))

                                    Image(systemName: "document.on.document.fill")
                                        .font(.system(size: 20, weight: .bold))
                                }
                            }
                            .buttonStyle(CapsuleIconButtonStyle())
                            .scaleEffect(isPressingCopyButton ? 0.92 : 1.0)
                            .opacity(isPressingCopyButton ? 0.85 : 1.0)
                            .animation(.spring(response: 0.22, dampingFraction: 0.6), value: isPressingCopyButton)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .updating($isPressingCopyButton) { _, state, _ in
                                        state = true
                                    }
                            )
                            .padding(.bottom)

                            Spacer()
                        }
                    }
                }

                ZStack {
                    BackgroundCard()
                        .frame(maxWidth: .infinity, maxHeight: 130)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add a friend")
                            .font(.system(size: 24, weight: .bold))
                        
                        HStack {
                            TextField("Add Friend", text: $newFriendUUIDString)
                                .disableAutocorrection(true)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                            
                            Button {
                                guard let activeUserID = authViewModel.userID else { return }
                                Task {
                                    if let friendUUID = UUIDToString(from: newFriendUUIDString) {
                                        await relationshipViewModel.insertRelationship(
                                            requesterID: activeUserID,
                                            addresseeID: friendUUID,
                                            refreshFor: activeUserID
                                        )
                                    }
                                }
                                
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                        
                    }
                    .padding(24)
                }
            }
            .padding()
            .padding(.horizontal, 10)
            .padding(.bottom, 75)
        }
        .appBackground()
        .onAppear {
            guard let activeUserID = authViewModel.userID else { return }
            Task { await relationshipViewModel.getRelationships(userID: activeUserID) }
        }
    }
    
    private func UUIDToString(from string: String) -> UUID? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return UUID(uuidString: trimmed)
    }
}

#Preview {
    let authVM = AuthViewModel()

    let vm = RelationshipViewModel()
    vm.relationships = [
        Relationship(
            requesterID: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            addresseeID: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            status: .accepted,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        Relationship(
            requesterID: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            addresseeID: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
            status: .pending,
            createdAt: Date().addingTimeInterval(-7200)
        ),
        Relationship(
            requesterID: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            addresseeID: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
            status: .blocked,
            createdAt: Date().addingTimeInterval(-10800)
        )
    ]

    return RelationshipView()
        .environmentObject(authVM)
        .environmentObject(vm)
}
