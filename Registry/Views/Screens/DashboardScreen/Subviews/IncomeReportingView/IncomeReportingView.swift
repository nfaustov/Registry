//
//  IncomeReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 09.06.2024.
//

import SwiftUI

struct IncomeReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        GroupBox("Доходы") {
            VStack {
                VStack {
                    ForEach(PaymentType.allCases, id: \.self) { type in
                        LabeledCurrency(type.rawValue, value: income(of: type))
                    }

                    Divider()

                    LabeledCurrency("Всего", value: income())
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
            }

//            if selectedPeriod != .day {
//                IncomeChart(date: date, selectedPeriod: selectedPeriod)
//                    .padding()
//                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
//                    .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
//            }
        }
        .groupBoxStyle(.reporting)
    }
}

#Preview {
    IncomeReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Subviews

private extension IncomeReportingView {
    @MainActor
    func income(of type: PaymentType? = nil) -> Double {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.income(for: date, period: selectedPeriod, of: type)
    }
}
