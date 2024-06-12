//
//  LedgerReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 09.06.2024.
//

import SwiftUI

struct LedgerReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        GroupBox("Доходы") {
            VStack {
                LabeledCurrency("Наличные", value: income(of: .cash))
                LabeledCurrency("Терминал", value: income(of: .bank))
                LabeledCurrency("Карта", value: income(of: .card))
                Divider()
                LabeledCurrency("Всего", value: income())
                    .font(.headline)
            }
            .padding()
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
        }
        .groupBoxStyle(.reporting)
    }
}

#Preview {
    LedgerReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Subviews

private extension LedgerReportingView {
    @MainActor
    func income(of type: PaymentType? = nil) -> Double {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.income(for: date, period: selectedPeriod, of: type)
    }
}
