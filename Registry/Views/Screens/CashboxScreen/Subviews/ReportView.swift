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
    @State private var isLoading: Bool = false

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
                    ProgressView()
                        .progressViewStyle(.circular)
                }

                if income > 0 {
                    Section {
                        ForEach(PaymentType.allCases, id: \.self) { type in
                            let income = report.reporting(.income, of: type)
                            if income > 0 {
                                HStack {
                                    Text(type.rawValue)
                                    Spacer()
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
                                HStack {
                                    Text(type.rawValue)
                                    Spacer()
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
        .task {
            isLoading = true

            Task {
                income = report.reporting(.income)
            }
            Task {
                expense = report.reporting(.expense)
            }
            Task {
                collected = report.collected
            }
            Task {
                cashBalance = report.cashBalance
            }

            isLoading = false
        }
    }
}

#Preview {
    ReportView(report: ExampleData.report)
        .previewInterfaceOrientation(.landscapeRight)
}
