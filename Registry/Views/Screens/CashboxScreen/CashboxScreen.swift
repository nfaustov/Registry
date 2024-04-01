//
//  CashboxScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI
import SwiftData
import Charts

struct CashboxScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Form {
                if let todayReport {
                    Section {
                        LabeledContent {
                            Button {
                                coordinator.present(.createSpending(in: todayReport))
                            } label: {
                                Text("Списание")
                            }
                            .disabled(user.accessLevel < .registrar)
                        } label: {
                            Text("\(Int(todayReport.cashBalance)) ₽")
                                .fontWeight(.medium)
                        }
                    }
                }

                Section {
                    if let todayReport {
                        Button("Отчет") {
                            coordinator.present(.report(todayReport))
                        }
                        .tint(.primary)
                    } else {
                        Button("Открыть смену") {
                            if let report = reports.first {
                                let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [])
                                modelContext.insert(newReport)
                            } else {
                                let firstReport = Report(date: .now, startingCash: 0, payments: [])
                                modelContext.insert(firstReport)
                            }
                        }
                        .disabled(user.accessLevel < .registrar)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(width: 320)

            Divider()
                .edgesIgnoringSafeArea(.all)

            PaymentsView(payments: todayReport?.payments ?? []) { payment in
                todayReport?.payments.removeAll(where: { $0 == payment })
            }
            .padding()
            .edgesIgnoringSafeArea([.all])
            .disabled(user.accessLevel < .registrar)
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
    var todayReport: Report? {
        if let report = reports.first, Calendar.current.isDateInToday(report.date) {
            return report
        } else {
            return nil
        }
    }
}
