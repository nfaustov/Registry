//
//  ExpenseReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 13.06.2024.
//

import SwiftUI

struct ExpenseReportingView: View {
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
                    ScrollView(.vertical) {
                        ForEach(expenses, id: \.self) { expense in
                            LabeledCurrency(expense.category.rawValue, value: expense.amount)
                                .environment(\.currencyAppearance, .floating)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollIndicators(.hidden)

                    Divider()

                    LabeledCurrency("Всего", value: expenses.reduce(0.0) { $0 + $1.amount })
                        .font(.headline)
                        .environment(\.currencyAppearance, .floating)
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
    ExpenseReportingView(date: .now, selectedPeriod: .day)
}

// MARK: - Calculations

private extension ExpenseReportingView {
    @MainActor
    var expenses: [PurposeExpense] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.expense(for: date, period: selectedPeriod)
            .sorted(by: { $0.amount < $1.amount})
    }
}
