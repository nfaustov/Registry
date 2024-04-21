//
//  UserDetailScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 28.03.2024.
//

import SwiftUI

struct UserDetailScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var currentDetail: UserDetailContext = .main

    // MARK: -

    var body: some View {
        SideBySideScreen(sidebarTitle: "Пользователь", detailTitle: currentDetail.title) {
            if user.image != nil {
                PersonImageView(person: user)
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
            }

            Section("ФИО") {
                Text(user.fullName)
            }

            Section("Должность") {
                Text(user.accessLevel.title)
            }

            if let doctor = user as? Doctor {
                Section("Баланс") {
                    LabeledContent("\(Int(doctor.balance)) ₽") {
                        Button("Выплата") {
                            coordinator.present(.updateBalance(for: doctor, kind: .payout))
                        }
                    }
                }
            }
        } detail: {
            detail
                .disabled(user.accessLevel < .registrar)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        coordinator.logOut()
                    }
                } label: {
                    Image(systemName: "figure.walk.departure")
                }
                .padding()
            }
        }
    }
}

#Preview {
    UserDetailScreen()
        .environmentObject(Coordinator())
}

// MARK: - Subviews

private extension UserDetailScreen {
    enum UserDetailContext {
        case main

        var title: String {
            switch self {
            case .main:
                return ""
            }
        }
    }

    @ViewBuilder var detail: some View {
        switch currentDetail {
        case .main:
            Form {
                Text(user.initials)
            }
        }
    }
}
