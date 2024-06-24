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

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        GroupBox("Пациенты") {
            HStack {
                VStack {
                    Text("\(uniquedPatients.count)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                    Text("Пациенты")
                        .foregroundStyle(.white)
                }
                .padding()
                .background(.indigo.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack {
                    reportLabel("Регистрации", value: scheduledPatients.count)
                    reportLabel("Визиты", value: completedVisitPatients.count)
                    reportLabel("Новые пациенты", value: newPatientsCount)
                }
                .padding(10)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
            }
        }
        .groupBoxStyle(.reporting)
    }
}

#Preview {
    PatientsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Subviews

private extension PatientsReportingView {
    func reportLabel(_ title: String, value: Int) -> some View {
        LabeledContent(title) {
            Text("\(value)")
                .fontWeight(.medium)
                .foregroundStyle(.indigo)
        }
    }
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
        uniquedPatients
            .filter { $0.isNewPatient(for: date, period: selectedPeriod) }
            .count
    }
}
