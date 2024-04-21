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
                Task {
                    let ledger = Ledger(modelContainer: modelContext.container)

                    paymentMethod.value = kind == .refill ?
                    abs(paymentMethod.value) :
                    -abs(paymentMethod.value)

                    await ledger.makeBalancePayment(from: person, method: paymentMethod, createdBy: user)
                }
            }
        }
    }
}

#Preview {
    UpdateBalanceView(person: ExampleData.doctor, kind: .payout)
}

// MARK: - UpdateBalanceKind

enum UpdateBalanceKind: String {
    case refill = "Пополнение"
    case payout = "Выплата"
}
