//
//  UpdateBalanceView.swift
//  Registry
//
//  Created by Николай Фаустов on 04.04.2024.
//

import SwiftUI
import SwiftData

struct UpdateBalanceView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    private let person: AccountablePerson
    private let kind: UpdateBalanceKind

    // MARK: - State

    @State private var paymentMethod: Payment.Method

    // MARK: -

    init(person: AccountablePerson, kind: UpdateBalanceKind) {
        self.person = person
        self.kind = kind

        if kind == .payout {
            _paymentMethod = State(
                initialValue: Payment.Method(
                    .cash,
                    value: person.balance < 0 ? 0 : person.balance
                )
            )
        } else {
            _paymentMethod = State(
                initialValue: Payment.Method(
                    .cash,
                    value: person.balance > 0 ? 0 : -person.balance
                )
            )
        }
    }

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

                Section("Способ оплаты") {
                    Text(paymentMethod.type.rawValue)
                        .foregroundStyle(.secondary)
                }

                Section {
                    TextField("Сумма", value: $paymentMethod.value, format: .number)
                } header: {
                    Text("Сумма")
                }
            }
            .sheetToolbar(title: kind.rawValue, confirmationDisabled: paymentMethod.value == 0) {
                paymentMethod.value = kind == .refill ? 
                abs(paymentMethod.value) :
                -abs(paymentMethod.value)

                person.updateBalance(increment: paymentMethod.value)

                let payment = Payment(
                    purpose: kind == .refill ? .toBalance(person.initials) : .fromBalance(person.initials),
                    methods: [paymentMethod],
                    createdBy: user.asAnyUser
                )

                if let todayReport {
                    todayReport.makePayment(payment)
                } else {
                    createReportWithPayment(payment)
                }
            }
        }
    }
}

#Preview {
    UpdateBalanceView(person: ExampleData.doctor, kind: .payout)
}

// MARK: - Calculations

private extension UpdateBalanceView {
    var todayReport: Report? {
        if let report = reports.first, Calendar.current.isDateInToday(report.date) {
            return report
        } else {
            return nil
        }
    }

    func createReportWithPayment(_ payment: Payment) {
        if let report = reports.first {
            let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [payment])
            modelContext.insert(newReport)
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [payment])
            modelContext.insert(firstReport)
        }
    }
}

// MARK: - UpdateBalanceKind

enum UpdateBalanceKind: String {
    case refill = "Пополнение"
    case payout = "Выплата"
}
