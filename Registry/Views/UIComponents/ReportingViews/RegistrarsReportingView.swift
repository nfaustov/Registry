//
//  RegistrarsReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import SwiftUI

struct RegistrarsReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        GroupBox("Активность регистраторов") {
            if registrarActivity.isEmpty {
                ContentUnavailableView("Нет данных", systemImage: "tray")
            } else {
                VStack {
                    ForEach(registrarActivity, id: \.self) { activity in
                        LabeledContent {
                            Text("\(activity.activity)")
                                .fontWeight(.medium)
                        } label: {
                            HStack {
                                PersonImageView(person: activity.registrar)
                                    .frame(width: 48, height: 48, alignment: .top)
                                    .clipShape(Circle())

                                Text(activity.registrar.fullName)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
            }
        }
        .groupBoxStyle(.reporting)
    }
}

#Preview {
    RegistrarsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculations

private extension RegistrarsReportingView {
    @MainActor
    var registrarActivity: [RegistrarActivity] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.registrarActivity(for: date, period: selectedPeriod)
    }
}
