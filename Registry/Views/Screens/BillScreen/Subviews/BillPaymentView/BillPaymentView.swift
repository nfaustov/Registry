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
    private let patient: Patient
    @Binding private var isPaid: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil

    // MARK: -

    init(patient: Patient, check: Check, isPaid: Binding<Bool>) {
        self.patient = patient
        self.check = check
        _isPaid = isPaid

        let paymentAmount = check.totalPrice - patient.balance
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: paymentAmount))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Пациент") {
                    Text(patient.fullName)
                    LabeledCurrency("К оплате", value: check.totalPrice - patient.balance)
                            .font(.headline)
                }

                CreatePaymentView(
                    account: patient,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )
                .paymentKind(.bill(totalPrice: check.totalPrice))
            }
            .sheetToolbar(
                "Оплата счёта",
                disabled: check.totalPrice - patient.balance == 0 ? false : undefinedPaymentValues
            ) {
                let ledger = Ledger(modelContext: modelContext)
                ledger.makePayment(
                    .medicalService(patient: patient, check: check, methods: paymentMethods),
                    createdBy: user
                )

                isPaid = true
            }
        }
    }
}

#Preview {
    BillPaymentView(
        patient: ExampleData.patient,
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
