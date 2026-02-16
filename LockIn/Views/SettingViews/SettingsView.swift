//
//  SettingsView.swift
//  LockIn
//
//  Created by Multazim Mesbah on 15/1/2026.
//
import SwiftUI

struct SettingItem {
    let label: String
    let value: String
    let icon: String
}

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("BOOL_BACKGROUNDPREFERENCE") var showWallpaper = false

    private var userEmail: String {
        authViewModel.session?.user.email ?? "Not signed in"
    }

    private var userIDString: String {
        authViewModel.userID?.uuidString ?? "Not signed in"
    }
    
    private var userCreatedAt: String {
        if let date = authViewModel.session?.user.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            return "Not signed in"
        }
    }

    private var appVersionString: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    private var appBuildString: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }

    private var appVersionDisplay: String {
        // Example: "1.4.3 (102)" where 1.4.3 is MARKETING_VERSION and 102 is CURRENT_PROJECT_VERSION
        "\(appVersionString) (\(appBuildString))"
    }

    private var items: [SettingItem] {
        [
            .init(label: "Email", value: userEmail, icon: "envelope.fill"),
            .init(label: "User ID", value: userIDString, icon: "person.fill"),
            .init(label: "Created", value: userCreatedAt, icon: "calendar"),
            .init(label: "Version", value: appVersionDisplay, icon: "gear")
        ]
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundCard() {
                VStack(spacing: 12) {
                    Text("Your Settings")
                        .font(.system(size: 24, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    List {
                        ForEach(items, id: \.label) { item in
                            HStack {
                                Image(systemName: item.icon)
                                Text(item.label)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(item.value)
                                    .foregroundStyle(.secondary)
                            }
                            .listRowBackground(Color.clear)
                        }

                        HStack {
                            Toggle(isOn: self.$showWallpaper, label: {
                                Label("Wallpaper", systemImage: "photo")
                                    .foregroundStyle(.primary)
                            })
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .listSectionSeparator(.hidden)
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    Spacer()

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
            }
            .padding()
            .padding(.horizontal, 10)
            .padding(.bottom, 75)
        }
        .appBackground()
    }
}


#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
