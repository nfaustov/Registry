//
//  DashboardScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 06.06.2024.
//

import SwiftUI

struct DashboardScreen: View {
    // MARK: - State

    @State private var date: Date = .now
    @State private var selectedPeriod: StatisticsPeriod = .day

    // MARK: -

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 32) {
                DatePicker("", selection: $date, displayedComponents: .date)
                HStack {
                    DateText(selectedPeriod.start(for: date), format: .date)
                        .font(.subheadline)
                    Text("-")
                        .font(.subheadline)
                    DateText(selectedPeriod.end(for: date), format: .date)
                        .font(.subheadline)
                    Picker("Выбранный период", selection: $selectedPeriod) {
                        ForEach(StatisticsPeriod.allCases) { period in
                            Text(period.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.secondary)
                    .frame(width: 100, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .padding(8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .frame(maxWidth: .infinity)

            HStack(spacing: 4) {
                VStack(spacing: 4) {
                    PatientsReportingView(date: date, selectedPeriod: selectedPeriod)
                    PricelistItemsReportingView(date: date, selectedPeriod: selectedPeriod)
                }
                .frame(width: 400)

                VStack(spacing: 4) {
                    LedgerReportingView(date: date, selectedPeriod: selectedPeriod)
                        .frame(maxWidth: .infinity)
                }

                VStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundStyle(.regularMaterial)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(4)
    }
}

#Preview {
    DashboardScreen()
}
