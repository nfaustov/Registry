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

    // MARK: - State

    @State private var date: Date = .now
    @State private var selectedPeriod: StatisticsPeriod = .day
    @State private var selectedReport: Report?

    // MARK: -

    var body: some View {
        ReportingView("Доходы", for: $date, selectedPeriod: $selectedPeriod) {
            VStack {
                if let selectedReport {
                    GroupBox("Выручка") {
                        LabeledCurrency("Наличные", value: selectedReport.billsIncome(of: .cash))
                        LabeledCurrency("Терминал", value: selectedReport.billsIncome(of: .bank))
                        LabeledCurrency("Карта", value: selectedReport.billsIncome(of: .card))
                        LabeledCurrency("Всего", value: selectedReport.billsIncome())
                            .font(.headline)
                    }

                    let sortedPayments = selectedReport.payments?
                        .sorted(by: { $0.date > $1.date })
                        .prefix(5)

                    VStack {
                        ForEach(sortedPayments ?? []) { payment in
                            LabeledContent(payment.purpose.title) {
                                CurrencyText(payment.totalAmount)
                                    .foregroundStyle(paymentColor(payment))
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .task {
            let ledger = Ledger(modelContext: modelContext)
            selectedReport = ledger.getReport(forDate: date)
        }
    }
}

#Preview {
    LedgerReportingView()
}

// MARK: - Subviews

private extension LedgerReportingView {
    func paymentColor(_ payment: Payment) -> Color {
        if payment.totalAmount < 0 {
            if payment.purpose == .collection {
                return .purple
            } else {
                return .red
            }
        } else {
            return .primary
        }
    }
}
