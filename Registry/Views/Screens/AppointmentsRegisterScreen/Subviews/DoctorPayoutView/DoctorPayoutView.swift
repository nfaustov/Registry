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
    private let isSinglePatient: Bool

    // MARK: - State

    @State private var balance: Double
    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil
    @State private var showLastTransactions: Bool = false

    // MARK: -

    init(doctor: Doctor, disabled: Bool, isSinglePatient: Bool) {
        self.doctor = doctor
        self.disabled = disabled
        self.isSinglePatient = isSinglePatient
        _balance = State(initialValue: doctor.balance)
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: doctor.balance < 0 ? 0 : floor(doctor.balance)))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Врач") {
                    Text(doctor.fullName)

                    LabeledContent("Баланс") {
                        CurrencyText(balance)
                            .font(.headline)
                            .foregroundStyle(doctor.balance < 0 ? .red : .primary)
                            .contentTransition(.numericText())
                    }

                    Button("Последние транзакции") {
                        showLastTransactions = true
                    }
                    .sheet(isPresented: $showLastTransactions) {
                        NavigationStack {
                            DoctorTransactionsView(doctor: doctor)
                                .sheetToolbar("Транзакции")
                        }
                    }
                }

                if isSinglePatient, singlePatientFee > 0 {
                    Section {
                        LabeledCurrency("Доплата за прием", value: singlePatientFee)
                    } footer: {
                        Text("Будет зачислена на баланс врача после проведения платежа.")
                    }
                }

                CreatePaymentView(
                    account: doctor,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )
                .paymentKind(.balance)
            }
            .sheetToolbar("Выплата", disabled: paymentMethod.value == 0 || disabled) {
                if isSinglePatient, singlePatientFee > 0 {
                    doctor.updateBalance(increment: singlePatientFee)
                    let purpose: Payment.Purpose = .toBalance("Доплата за прием")
                    let payment = Payment(purpose: purpose, methods: [.init(.cash, value: singlePatientFee)], createdBy: user.asAnyUser)
                    doctor.transactions?.append(payment)
                }

                let ledger = Ledger(modelContainer: modelContext.container)
                await ledger.makeDoctorPayoutPayment(doctor: doctor, methods: paymentMethods, createdBy: user)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#Preview {
    DoctorPayoutView(doctor: ExampleData.doctor, disabled: false, isSinglePatient: false)
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

    var singlePatientFee: Double {
        switch doctor.secondName {
        case "Окунцова": return 500
        case "Безрукавников": return 250
        default: return 0
        }
    }
}
