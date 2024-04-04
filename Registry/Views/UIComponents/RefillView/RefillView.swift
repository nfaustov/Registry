//
//  RefillView.swift
//  Registry
//
//  Created by Николай Фаустов on 04.04.2024.
//

import SwiftUI
import SwiftData

struct RefillView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    @Binding var person: Person

    @State private var value: Double = .zero

    // MARK: -

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(person.fullName)
                    LabeledContent("Баланс") {
                        Text("\(Int(person.balance)) ₽")
                            .font(.headline)
                            .foregroundStyle(person.balance < 0 ? .red : .primary)
                    }
                }

                Section {
                    TextField("Сумма", value: $value, format: .number)
                } header: {
                    Text("Сумма")
                }
            }
            .sheetToolbar(
                title: "Пополнение",
                confirmationDisabled: value == 0
            ) {
                let totalValue = abs(value)
                person.balance += totalValue

                let payment = Payment(
                    purpose: .toBalance(person.initials),
                    methods: [Payment.Method(.cash, value: totalValue)],
                    createdBy: user.asAnyUser
                )

                if let todayReport {
                    todayReport.payments.append(payment)
                } else {
                    createReportWithPayment(payment)
                }
            }
        }
    }
}

#Preview {
    RefillView(person: .constant(ExampleData.doctor))
}

// MARK: - Calculations

private extension RefillView {
    var todayReport: Report? {
        if let report = reports.first, Calendar.current.isDateInToday(report.date) {
            return report
        } else {
            return nil
        }
    }

    func createReportWithPayment(_ payment: Payment) {
        if let report = reports.first {
            let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [])
            modelContext.insert(newReport)
            newReport.payments.append(payment)
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [])
            modelContext.insert(firstReport)
            firstReport.payments.append(payment)
        }
    }
}
