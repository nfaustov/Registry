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

    @EnvironmentObject private var coordinator: Coordinator

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: - State

    @State private var reportingType: ReportingType = .visits

    // MARK: -

    var body: some View {
        GroupBox {
            if reportingType == .visits {
                VStack {
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

                    Button {
                        coordinator.present(.patientsReportingDetail)
                    } label: {
                        LabeledContent("Побробнее") {
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.indigo)
                    }
                    .padding(10)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
                }
            } else if reportingType == .revenue {
                if patientsRevenue.isEmpty {
                    ContentUnavailableView("Нет данных", systemImage: "tray")
                } else {
                    ScrollView(.vertical) {
                        ForEach(patientsRevenue, id: \.self) { revenue in
                            LabeledContent {
                                Text("\(revenue.revenue)")
                                    .fontWeight(.medium)
                            } label: {
                                Text(revenue.patient.fullName)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollIndicators(.hidden)
                }
            }
        } label: {
            LabeledContent("Пациенты") {
                Picker("", selection: $reportingType) {
                    ForEach(ReportingType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .tint(.secondary)
            }
        }
        .groupBoxStyle(.reporting)
        .animation(.linear, value: reportingType)
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
    enum ReportingType: String, CaseIterable {
        case visits = "Посещаемость"
        case revenue = "Выручка"
    }

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

    @MainActor
    var patientsRevenue: [PatientRevenue] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.patientsRevenue(for: date, period: selectedPeriod, maxCount: 10)
    }
}
