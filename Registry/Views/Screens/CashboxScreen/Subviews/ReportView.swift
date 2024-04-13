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

    @State private var expense: Double = 0
    @State private var collected: Double = 0
    @State private var cashBalance: Double = 0

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

                if !report.payments.filter({ $0.subject != nil }).isEmpty {
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

                if !report.payments.filter({ $0.subject == nil }).isEmpty {
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
            Task {
                expense = report.reporting(.expense)
            }
            Task {
                collected = report.collected
            }
            Task {
                cashBalance = report.cashBalance
            }
        }
    }
}

#Preview {
    ReportView(report: ExampleData.report)
        .previewInterfaceOrientation(.landscapeRight)
}
