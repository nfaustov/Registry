//
//  ExpenseReportintView.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import SwiftUI

struct ExpenseReportintView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: -

    var body: some View {
        GroupBox("Расходы") {
            if expenses.isEmpty {
                ContentUnavailableView("Нет данных", systemImage: "tray")
            } else {
                VStack {
                    ForEach(expenses, id: \.self) { expense in
                        LabeledCurrency(expense.purposeTitle, value: expense.amount)
                    }

                    Divider()

                    LabeledCurrency("Всего", value: expenses.reduce(0.0) { $0 + $1.amount })
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)

                Spacer()
            }
        }
        .groupBoxStyle(.reporting)
    }
}

#Preview {
    ExpenseReportintView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculations

private extension ExpenseReportintView {
    @MainActor
    var expenses: [PurposeExpense] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.expense(for: date, period: selectedPeriod)
    }
}
