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

    private let appointment: PatientAppointment
    private let check: Check
    private let patient: Patient
    @Binding private var isPaid: Bool

    // MARK: - State

    @State private var paymentMethod: Payment.Method
    @State private var additionalPaymentMethod: Payment.Method? = nil

    // MARK: -

    init(appointment: PatientAppointment, isPaid: Binding<Bool>) {
        self.appointment = appointment
        _isPaid = isPaid

        guard let patient = appointment.patient,
              let check = appointment.check else { fatalError() }

        self.patient = patient
        self.check = check
        let paymentAmount = check.totalPrice - patient.balance
        _paymentMethod = State(initialValue: Payment.Method(.cash, value: paymentAmount))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Пациент") {
                    Text(patient.fullName)
                    LabeledContent("К оплате") {
                        Text("\(Int(check.totalPrice - patient.balance)) ₽")
                            .font(.headline)
                    }
                }

                CreatePaymentView(
                    account: patient,
                    paymentMethod: $paymentMethod,
                    additionalPaymentMethod: $additionalPaymentMethod
                )
                .paymentKind(.bill(totalPrice: check.totalPrice))
            }
            .sheetToolbar(title: "Оплата счёта", confirmationDisabled: undefinedPaymentValues) {
                Task {
                    let ledger = Ledger(modelContainer: modelContext.container)

                    if paymentBalance != 0 {
                        var balancePaymentMethod = paymentMethod
                        balancePaymentMethod.value = paymentBalance
                        await ledger.makeBalancePayment(from: patient, method: balancePaymentMethod, createdBy: user)
                    }

                    await ledger.makeMedicalServicePayment(from: patient, methods: paymentMethods, check: check, cretaedBy: user)
                }

                isPaid = true
            }
        }
    }
}

#Preview {
    BillPaymentView(
        appointment: ExampleData.appointment,
        isPaid: .constant(false)
    )
}

// MARK: - Calculations

private extension BillPaymentView {
    var undefinedPaymentValues: Bool {
        guard let additionalPaymentMethod else { return paymentMethod.value == 0 }
        return additionalPaymentMethod.value == 0 || paymentMethod.value == 0
    }

    var paymentBalance: Double {
        paymentMethod.value + (additionalPaymentMethod?.value ?? 0) - check.totalPrice
    }

    var paymentMethods: [Payment.Method] {
        var methods = [Payment.Method]()

        if let additionalPaymentMethod {
            methods.append(additionalPaymentMethod)
        } else {
            paymentMethod.value = check.totalPrice
        }

        methods.append(paymentMethod)

        return methods
    }
}
