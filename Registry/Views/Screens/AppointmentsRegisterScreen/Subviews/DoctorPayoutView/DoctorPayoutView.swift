//
//  DoctorPayoutView.swift
//  Registry
//
//  Created by Николай Фаустов on 26.02.2024.
//

import SwiftUI
import SwiftData

struct DoctorPayoutView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    private let doctor: Doctor
    private let disabled: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil
    @State private var showLastTransactions: Bool = false

    // MARK: -

    init(doctor: Doctor, disabled: Bool) {
        self.doctor = doctor
        self.disabled = disabled
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: doctor.balance < 0 ? 0 : doctor.balance))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Врач") {
                    Text(doctor.fullName)

                    LabeledContent("Баланс") {
                        Text("\(Int(doctor.balance)) ₽")
                            .font(.headline)
                            .foregroundStyle(doctor.balance < 0 ? .red : .primary)
                    }

                    Button("Последние транзакции") {
                        showLastTransactions = true
                    }
                    .sheet(isPresented: $showLastTransactions) {
                        NavigationStack {
                            DoctorTransactionsView(doctor: doctor)
                                .sheetToolbar(title: "Транзакции")
                        }
                    }
                }

                CreatePaymentView(
                    account: doctor,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )
                .paymentKind(.balance)
            }
            .sheetToolbar(
                title: "Выплата",
                confirmationDisabled: paymentMethod.value == 0 || disabled
            ) {
                Task {
                    let ledger = Ledger(modelContainer: modelContext.container)
                    await ledger.makeDoctorPayoutPayment(doctor: doctor, methods: paymentMethods, createdBy: user)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    DoctorPayoutView(doctor: ExampleData.doctor, disabled: false)
}

// MARK: - Calculations

private extension DoctorPayoutView {
    var paymentMethods: [Payment.Method] {
        paymentMethod.value = -abs(paymentMethod.value)
        var methods = [paymentMethod]

        if var additionalPaymentMethod {
            additionalPaymentMethod.value = -abs(additionalPaymentMethod.value)
            methods.append(additionalPaymentMethod)
        }

        return methods
    }
}
