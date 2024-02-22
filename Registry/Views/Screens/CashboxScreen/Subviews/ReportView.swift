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

                if report.reporting(.income) > 0 {
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

                if report.reporting(.expense) < 0 {
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

                if report.collected != 0 {
                    Section {
                        HStack {
                            Text("Инкассация")
                            Spacer()
                            Text("\(Int(report.collected)) ₽")
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.purple)
                    }
                }

                Section {
                    HStack {
                        Text("Остаток в кассе")
                        Spacer()
                        Text("\(Int(report.cashBalance)) ₽")
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
    }
}

#Preview {
    ReportView(report: ExampleData.report)
        .previewInterfaceOrientation(.landscapeRight)
}
