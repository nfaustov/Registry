//
//  ReportView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct ReportView: View {
    // MARK: - Dependencies

    let report: Report

    // MARK: - State

    @State private var isCashBalanceLoading: Bool = true
    @State private var isCollectedLoading: Bool = true

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledCurrency("Открытие смены", value: report.startingCash)
                        .foregroundStyle(.secondary)
                }

                if report.hasBillIncome {
                    Section("Доход") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let billIncome = report.billsIncome(of: type)
                            if billIncome > 0 {
                                LabeledCurrency(type.rawValue, value: billIncome)
                            }
                        }
                    }
                }

                if report.hasOtherIncome {
                    Section("Пополнения") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let othersIncome = report.othersIncome(of: type)
                            if othersIncome > 0 {
                                LabeledCurrency(type.rawValue, value: othersIncome)
                            }
                        }
                    }
                }

                if report.hasExpense {
                    Section("Списания") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let expense = report.reporting(.expense, of: type)
                            if expense < 0 {
                                LabeledCurrency(type.rawValue, value: expense)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }

                if report.collected != 0 {
                    Section {
                        LabeledCurrency("Инкассация", value: report.collected)
                            .foregroundStyle(.purple)
                    }
                }

                Section {
                    LabeledCurrency("Остаток в кассе", value: report.cashBalance)
                        .foregroundStyle(.secondary)
                }
            }
            .sheetToolbar(
                "Отчет",
                subtitle: DateFormat.weekDay.string(from: report.date)
            )
        }
    }
}

#Preview {
    ReportView(report: ExampleData.report)
        .previewInterfaceOrientation(.landscapeRight)
}
