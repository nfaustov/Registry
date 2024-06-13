//
//  DoctorsReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import SwiftUI

struct DoctorsReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        GroupBox("Специалисты") {
            if doctorsPopularity.isEmpty {
                ContentUnavailableView("Нет данных", systemImage: "tray")
            } else {
                ForEach(doctorsPopularity, id: \.self) { popularity in
                    LabeledContent {
                        Text("\(popularity.patientsCount)")
                            .fontWeight(.medium)
                    } label: {
                        DoctorView(doctor: popularity.doctor, presentation: .listRow)
                    }
                }

                Spacer()
            }
        }
        .groupBoxStyle(.reporting)
    }
}

#Preview {
    DoctorsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculations

private extension DoctorsReportingView {
    @MainActor
    var doctorsPopularity: [DoctorsPopularity] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.topDoctorsByPatients(for: date, period: selectedPeriod, maxCount: 5)
    }
}
