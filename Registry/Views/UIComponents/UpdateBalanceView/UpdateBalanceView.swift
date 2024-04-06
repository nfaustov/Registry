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

    @Binding var person: Person

    private let kind: UpdateBalanceKind

    // MARK: - State

    @State private var paymentMethod: Payment.Method

    // MARK: -

    init(person: Binding<Person>, kind: UpdateBalanceKind) {
        _person = person
        self.kind = kind

        if kind == .payout {
            _paymentMethod = State(
                initialValue: Payment.Method(
                    .cash,
                    value: person.wrappedValue.balance < 0 ? 0 : person.wrappedValue.balance
                )
            )
        } else {
            _paymentMethod = State(
                initialValue: Payment.Method(
                    .cash,
                    value: person.wrappedValue.balance > 0 ? 0 : -person.wrappedValue.balance
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

                person.balance += paymentMethod.value

                let payment = Payment(
                    purpose: kind == .refill ? .toBalance(person.initials) : .fromBalance(person.initials),
                    methods: [paymentMethod],
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
    UpdateBalanceView(person: .constant(ExampleData.doctor), kind: .payout)
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

// MARK: - UpdateBalanceKind

enum UpdateBalanceKind: String {
    case refill = "Пополнение"
    case payout = "Выплата"
}
