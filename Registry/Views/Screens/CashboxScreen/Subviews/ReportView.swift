//
//  ReportView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct ReportView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let report: Report

    // MARK: - State

    @State private var isCashBalanceLoading: Bool = true
    @State private var isCollectedLoading: Bool = true
    @State private var isClosingInProgress: Bool = false

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledCurrency("Открытие смены", value: report.startingCash)
                        .foregroundStyle(.secondary)
                }

                if report.billsIncome() != 0 {
                    Section("Доход") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let billIncome = report.billsIncome(of: type)
                            if billIncome > 0 {
                                LabeledCurrency(type.rawValue, value: billIncome)
                            }
                        }
                    }
                }

                if report.othersIncome() != 0 {
                    Section("Пополнения") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let othersIncome = report.othersIncome(of: type)
                            if othersIncome > 0 {
                                LabeledCurrency(type.rawValue, value: othersIncome)
                            }
                        }
                    }
                }

                if report.reporting(.expense) != 0 {
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

                Section {
                    Button {
                        isClosingInProgress = true
                        let ledger = Ledger(modelContext: modelContext)
                        ledger.closeReport()
                        isClosingInProgress = false
                    } label: {
                        HStack {
                            Text("Закрыть смену")

                            if isClosingInProgress {
                                CircularProgressView()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .disabled(report.closed)
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
