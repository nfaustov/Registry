//
//  PatientsReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 07.06.2024.
//

import SwiftUI

struct PatientsReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var date: Date = .now
    @State private var selectedPeriod: StatisticsPeriod = .day

    // MARK: -

    var body: some View {
        ReportingView("Пациенты", for: $date, selectedPeriod: $selectedPeriod) {
            VStack {
                LabeledContent("Регистраций", value: "\(scheduledPatients.count)")
                LabeledContent("Завершенные приемы", value: "\(completedVisitPatients.count)")
                LabeledContent("Пациенты", value: "\(uniquedPatients.count)")
                LabeledContent("Новые пациенты", value: "\(newPatientsCount)")
            }
            .padding()
        }
    }
}

#Preview {
    PatientsReportingView()
}

// MARK: - Calculation

private extension PatientsReportingView {
    @MainActor
    var completedVisitPatients: [Patient] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.completedVisitPatients(for: date, period: selectedPeriod)
    }

    @MainActor
    var scheduledPatients: [Patient] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.scheduledPatients(for: date, period: selectedPeriod)
    }

    @MainActor
    var uniquedPatients: [Patient] {
        Array(completedVisitPatients.uniqued())
    }

    @MainActor
    var newPatientsCount: Int {
        scheduledPatients
            .filter { $0.isNewPatient(for: date, period: selectedPeriod) }
            .count
    }
}
