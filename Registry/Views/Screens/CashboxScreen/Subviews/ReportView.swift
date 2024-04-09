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

    @State private var income: Double = 0
    @State private var expense: Double = 0
    @State private var collected: Double = 0
    @State private var cashBalance: Double = 0
    @State private var isLoading: Bool = true

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Открытие смены")
                        Spacer()
                        Text("\(Int(report.startingCash)) ₽")
                    }
                }

                if isLoading {
                    Section {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.blue)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                if income > 0 {
                    Section {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let income = report.reporting(.income, of: type)
                            if income > 0 {
                                LabeledContent(type.rawValue) {
                                    Text("\(Int(income)) ₽")
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    } header: {
                        Text("Доход")
                    }
                }

                if expense < 0 {
                    Section {
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
                    } header: {
                        Text("Расход")
                    }
                }

                if collected != 0 {
                    Section {
                        HStack {
                            Text("Инкассация")
                            Spacer()
                            Text("\(Int(collected)) ₽")
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.purple)
                    }
                }

                Section {
                    HStack {
                        Text("Остаток в кассе")
                        Spacer()
                        Text("\(Int(cashBalance)) ₽")
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .sheetToolbar(
                title: "Отчет",
                subtitle: DateFormat.weekDay.string(from: report.date)
            )
        }
        .onAppear {
            var incomeFinished = false
            var expenseFinished = false
            var collectedFinished = false
            var cashBalanceFinished = false

            Task {
                income = report.reporting(.income)
                incomeFinished = true
            }
            Task {
                expense = report.reporting(.expense)
                expenseFinished = true
            }
            Task {
                collected = report.collected
                collectedFinished = true
            }
            Task {
                cashBalance = report.cashBalance
                cashBalanceFinished = true
            }

            isLoading = incomeFinished && expenseFinished && collectedFinished && cashBalanceFinished
        }
    }
}

#Preview {
    ReportView(report: ExampleData.report)
        .previewInterfaceOrientation(.landscapeRight)
}
