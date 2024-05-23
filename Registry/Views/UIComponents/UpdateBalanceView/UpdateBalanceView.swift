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
                    value: person.balance >= 0 ? 0 : -person.balance
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
                        CurrencyText(person.balance)
                            .font(.headline)
                            .foregroundStyle(person.balance < 0 ? .red : .primary)
                    }
                }

                MoneyFieldSection(paymentMethod.type.rawValue, value: $paymentMethod.value)
            }
            .sheetToolbar(kind.rawValue, disabled: paymentMethod.value == 0) {
                let paymentsController = PaymentsController(modelContainer: modelContext.container)
                await paymentsController.makePayment(
                    .balance(kind, person: person, method: paymentMethod),
                    createdBy: user
                )
            }
        }
    }
}

#Preview {
    UpdateBalanceView(person: ExampleData.doctor, kind: .payout)
}
