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

    // MARK: - State

    @State private var reportingType: ReportingType = .popularity

    // MARK: -

    var body: some View {
        GroupBox {
            if reportingType == .popularity {
                indicatorView(indicator: doctorsPopularity)
            } else if reportingType == .revenue {
                indicatorView(indicator: doctorsRevenue)
            } else if reportingType == .agentFee {
                indicatorView(indicator: doctorsAgentFee)
            }
        } label: {
            LabeledContent("Специалисты") {
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
    DoctorsReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculations

private extension DoctorsReportingView {
    enum ReportingType: String, CaseIterable {
        case popularity = "Популярность"
        case revenue = "Выручка"
        case agentFee = "Агентские"
    }

    @MainActor
    var doctorsPopularity: [DoctorIndicator] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.doctorsByPatients(for: date, period: selectedPeriod)
    }

    @MainActor
    var doctorsRevenue: [DoctorIndicator] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.doctorsRevenue(for: date, period: selectedPeriod)
    }

    @MainActor
    var doctorsAgentFee: [DoctorIndicator] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.doctorsAgentFee(for: date, period: selectedPeriod)
    }
}

// MARK: - Subviews

private extension DoctorsReportingView {
    @ViewBuilder func indicatorView(indicator: [DoctorIndicator]) -> some View {
        if indicator.isEmpty {
            ContentUnavailableView("Нет данных", systemImage: "tray")
        } else {
            ScrollView(.vertical) {
                ForEach(indicator, id: \.self) { indicator in
                    LabeledContent {
                        Text("\(indicator.indicator)")
                            .fontWeight(.medium)
                    } label: {
                        HStack {
                            PersonImageView(person: indicator.doctor)
                                .frame(width: 44, height: 44, alignment: .top)
                                .clipShape(Circle())

                            Text(indicator.doctor.fullName)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
    }
}
