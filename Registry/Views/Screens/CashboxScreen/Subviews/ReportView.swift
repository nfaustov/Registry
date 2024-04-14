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

    @State private var collected: Double = 0
    @State private var cashBalance: Double = 0
    @State private var isCashBalanceLoading: Bool = true
    @State private var isCollectedLoading: Bool = true

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Открытие смены", value: "\(Int(report.startingCash)) ₽")
                }

                if report.hasBillIncome {
                    Section("Доход") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let billIncome = report.billsIncome(of: type)
                            if billIncome > 0 {
                                LabeledContent(type.rawValue) {
                                    Text("\(Int(billIncome)) ₽")
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }

                if report.hasOtherIncome {
                    Section("Пополнения") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let othersIncome = report.othersIncome(of: type)
                            if othersIncome > 0 {
                                LabeledContent(type.rawValue) {
                                    Text("\(Int(othersIncome)) ₽")
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }

                if report.hasExpense {
                    Section("Списания") {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let expense = report.reporting(.expense, of: type)
                            if expense < 0 {
                                LabeledContent(type.rawValue) {
                                    Text("\(Int(expense)) ₽")
                                        .foregroundStyle(.red)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }

                if collected != 0 {
                    Section {
                        LabeledContent {
                            Text("\(Int(collected)) ₽")
                                .fontWeight(.medium)
                        } label: {
                            HStack {
                                Text("Инкассация")

                                if isCollectedLoading {
                                    CircularProgressView()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .foregroundStyle(.purple)
                    }
                }

                Section {
                    LabeledContent {
                        Text("\(Int(cashBalance)) ₽")
                            .fontWeight(.medium)
                    } label: {
                        HStack {
                            Text("Остаток в кассе")

                            if isCashBalanceLoading {
                                CircularProgressView()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .sheetToolbar(
                title: "Отчет",
                subtitle: DateFormat.weekDay.string(from: report.date)
            )
        }
        .task {
            Task {
                collected = report.collected
                isCollectedLoading = false
            }
            Task {
                cashBalance = report.cashBalance
                isCashBalanceLoading = false
            }
        }
    }
}

#Preview {
    ReportView(report: ExampleData.report)
        .previewInterfaceOrientation(.landscapeRight)
}
