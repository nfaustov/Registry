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

    @State private var currentDetail: UserDetailContext = .schedule

    // MARK: -

    var body: some View {
        SideBySideScreen(sidebarTitle: "Пользователь", detailTitle: currentDetail.title) {
            if user.image != nil {
                PersonImageView(person: user)
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
            }

            Section {
                Text(user.fullName)
            }

            Section("Должность") {
                Text(user.accessLevel.title)
            }

            Section {
                Button {
                    currentDetail = .schedule
                } label: {
                    Label("График работы", systemImage: "chart.dots.scatter")
                        .tint(.primary)
                }

                Button {
                    currentDetail = .kpi
                } label: {
                    Label("Ключевые показатели", systemImage: "chart.line.uptrend.xyaxis.circle")
                        .tint(.primary)
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
        case kpi
        case schedule

        var title: String {
            switch self {
            case .kpi:
                return "Ключевые показатели"
            case .schedule:
                return "График работы"
            }
        }
    }

    @ViewBuilder var detail: some View {
        switch currentDetail {
        case .kpi:
            RegistrarActivityView()
        case .schedule:
            RegistrarScheduleView()
        }
    }
}
