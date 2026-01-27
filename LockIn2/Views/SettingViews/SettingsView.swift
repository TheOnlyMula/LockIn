//
//  SettingsView.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 15/1/2026.
//
import SwiftUI

struct SettingItem {
    let label: String
    let value: String
}


struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    private var userEmail: String {
        authViewModel.session?.user.email ?? "Not available"
    }

    private var userIDString: String {
        authViewModel.userID?.uuidString ?? "Not signed in"
    }

    private var items: [SettingItem] {
        [
            .init(label: "Email", value: userEmail),
            .init(label: "User ID", value: userIDString)
        ]
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundCard()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .padding(.horizontal, 10)
                .padding(.bottom, 75)

            // Content that conforms to the card's interior
            VStack(spacing: 12) {
                Text("Your Settings")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 20)

                List {
                    ForEach(items, id: \.label) { item in
                        HStack {
                            Text(item.label)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(item.value)
                                .foregroundStyle(.secondary)
                        }
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

                Spacer(minLength: 12)

                Button {
                    Task { await authViewModel.signOut() }
                } label: {
                    HStack {
                        Text("Sign Out")
                        Image(systemName: "door.left.hand.open")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(CapsuleIconButtonStyle(tint: .red))
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding() // match the inner padding visually inside the card
            .padding(.horizontal, 30)
            .padding(.bottom, 105)
        }
        .appBackground()
    }
}


#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}