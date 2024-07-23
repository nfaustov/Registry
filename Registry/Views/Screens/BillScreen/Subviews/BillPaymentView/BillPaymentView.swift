//
//  BillPaymentView.swift
//  Registry
//
//  Created by Николай Фаустов on 27.02.2024.
//

import SwiftUI
import SwiftData

struct BillPaymentView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    private let check: Check
    private let person: AccountablePerson
    private let paymentAmount: Double
    @Binding private var isPaid: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil

    // MARK: -

    init(person: AccountablePerson, check: Check, isPaid: Binding<Bool>) {
        self.person = person
        self.check = check
        let balancePayment = person.balance > check.totalPrice ? check.totalPrice : person.balance
        self.paymentAmount = check.totalPrice - balancePayment
        _isPaid = isPaid
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: paymentAmount))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Пациент") {
                    Text(person.fullName)
                    LabeledCurrency("К оплате", value: paymentAmount)
                            .font(.headline)
                }

                CreatePaymentView(
                    account: person,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )
                .paymentKind(.bill(totalPrice: check.totalPrice))
            }
            .sheetToolbar(
                "Оплата счёта",
                disabled: paymentAmount == 0 ? false : undefinedPaymentValues
            ) {
                let ledger = Ledger(modelContext: modelContext)
                try ledger.makePayment(
                    .medicalService(person: person, check: check, methods: paymentMethods),
                    createdBy: user
                )

                isPaid = true
            }
        }
    }
}

#Preview {
    BillPaymentView(
        person: ExampleData.patient,
        check: ExampleData.check,
        isPaid: .constant(false)
    )
}

// MARK: - Calculations

private extension BillPaymentView {
    var undefinedPaymentValues: Bool {
        guard let additionalPaymentMethod else { return paymentMethod.value == 0 }
        return additionalPaymentMethod.value == 0 || paymentMethod.value == 0
    }

    var paymentMethods: [Payment.Method] {
        var methods = [paymentMethod]

        if let additionalPaymentMethod { methods.append(additionalPaymentMethod) }

        return methods
    }
}
