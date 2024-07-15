//
//  RegistrarActivityView.swift
//  Registry
//
//  Created by Николай Фаустов on 28.06.2024.
//

import SwiftUI

struct RegistrarActivityView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var registrarActivity: [RegistrarActivity] = []
    @State private var isLoading: Bool = true

    // MARK: -

    var body: some View {
        Form {
            if let doctor = user as? Doctor, !doctor.achievements.isEmpty {
                Section("Награды") {
                    ForEach(doctor.achievements.sorted(by: { $0.issueDate > $1.issueDate })) { achievement in
                        LabeledContent {
                            Text(achievement.period)
                        } label: {
                            Label {
                                Text(achievement.kind.rawValue)
                            } icon: {
                                Image(systemName: achievement.kind.icon)
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                }
            }

            Section("Активность регистраторов") {
                if isLoading {
                    HStack {
                        Spacer()
                        CircularProgressView()
                        Spacer()
                    }
                } else {
                    ForEach(registrarActivity, id: \.self) { activity in
                        LabeledContent {
                            Text("\(activity.activity)")
                                .font(.headline)
                                .foregroundStyle(activity.registrar.id == user.id ? .primary : .secondary)
                        } label: {
                            HStack {
                                PersonImageView(person: activity.registrar)
                                    .frame(width: 60, height: 60, alignment: .top)
                                    .clipShape(Circle())
                                    .opacity(activity.registrar.id == user.id ? 1 : 0.75)

                                Text(activity.registrar.fullName)
                                    .foregroundStyle(activity.registrar.id == user.id ? .primary : .secondary)
                            }
                        }
                    }
                }
            }
            .task {
                let ledger = Ledger(modelContext: modelContext)
                registrarActivity = ledger.registrarActivity(for: .now, period: .month)
                isLoading = false
            }
        }
    }
}

#Preview {
    RegistrarActivityView()
}
