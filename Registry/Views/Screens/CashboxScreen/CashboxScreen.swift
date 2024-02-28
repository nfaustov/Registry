//
//  CashboxScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI
import SwiftData

struct CashboxScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @Query(sort: \Report.date, order: .forward) private var reports: [Report]

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                Form {
                    HStack {
                        Text("\(Int(todayReport.cashBalance)) ₽")
                            .fontWeight(.medium)

                        Spacer()

                        Button {
                            coordinator.present(.createSpending(in: todayReport))
                        } label: {
                            Text("Списание")
                        }
                    }
                    
                    Section {
                        DisclosureGroup("Доходы") {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if todayReport.reporting(.income, of: type) != 0 {
                                    AccountView(
                                        value: todayReport.reporting(.income, of: type),
                                        type: type,
                                        fraction: todayReport.fraction(.income, ofAccount: type)
                                    )
                                }
                            }
                        }
                        DisclosureGroup("Расходы") {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if todayReport.reporting(.expense, of: type) != 0 {
                                    AccountView(
                                        value: todayReport.reporting(.expense, of: type),
                                        type: type,
                                        fraction: todayReport.fraction(.expense, ofAccount: type))
                                }
                            }
                        }
                    }
                    .tint(.secondary)
                    .disabled(todayReport.payments.isEmpty)

                    Button {
                        coordinator.present(.report(todayReport))
                    } label: {
                        Text("Отчет")
                    }
                    .tint(.primary)
                }
                .frame(width: 400)
            }

            Divider()
                .edgesIgnoringSafeArea(.all)

            PaymentsView(payments: todayReport.payments) { payment in
                todayReport.payments.removeAll(where: { $0 == payment })
            }
            .padding()
            .edgesIgnoringSafeArea([.all])
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    CashboxScreen()
        .environmentObject(Coordinator())
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Calculations

private extension CashboxScreen {
    var todayReport: Report {
        if let report = reports.first {
            if Calendar.current.isDateInToday(report.date) {
                return report
            } else {
                let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [])
                modelContext.insert(newReport)

                return newReport
            }
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [])
            modelContext.insert(firstReport)

            return firstReport
        }
    }
}
