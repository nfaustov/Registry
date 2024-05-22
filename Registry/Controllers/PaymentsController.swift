//
//  PaymentsController.swift
//  Registry
//
//  Created by Николай Фаустов on 22.05.2024.
//

import Foundation
import SwiftData

final class PaymentsController: ObservableObject {
    @Published var proceedingPayments: [Payment] = []

    func make(_ sample: PaymentFactory.Sample, user: User, modelContainer: ModelContainer) async {
        let factory = PaymentFactory(producer: user)
        let payment = factory.make(from: sample)
        proceedingPayments.append(payment)

        let ledger = Ledger(modelContainer: modelContainer)
        await ledger.proceedPayment(payment, as: sample)
    }
}

struct PaymentFactory {
    let producer: User

    init(producer: User) {
        self.producer = producer
    }

    func make(from sample: PaymentFactory.Sample) -> Payment {
        switch sample {
        case .medicalService(let check, let methods):
            makeMedicalServicePayment(check: check, methods: methods)
        case .doctorPayout(let doctor, let methods):
            makeDoctorPayoutPayment(doctor: doctor, methods: methods)
        case .refund(let refund, let paymentType, let includeBalance):
            makeRefundPayment(refund: refund, paymentType: paymentType, includeBalance: includeBalance)
        case .balance(let kind, let person, let method):
            makeBalancePayment(kind, from: person, method: method)
        case .spending(let purpose, let method):
            makeSpendingPayment(purpose: purpose, method: method)
        }
    }
}

// MARK: - Private methods

private extension PaymentFactory {
    func makeMedicalServicePayment(check: Check, methods: [Payment.Method]) -> Payment {
        let paymentValue = methods.reduce(0.0) { $0 + $1.value }
        let paymentBalance = paymentValue - check.totalPrice
        let patient = check.appointments?.first?.patient
        var purpose: Payment.Purpose = .medicalServices(patient?.initials ?? "")

        if paymentBalance != 0 {
            purpose.descripiton.append(" (Записано на баланс \(Int(paymentBalance)) ₽)")
        }

        return Payment(
            purpose: purpose,
            methods: methods,
            subject: check,
            createdBy: producer.asAnyUser
        )
    }

    func makeDoctorPayoutPayment(doctor: Doctor, methods: [Payment.Method]) -> Payment {
        let paymentMethods = methods.map {
            Payment.Method($0.type, value: -abs($0.value))
        }

        return Payment(
            purpose: .doctorPayout("Врач: \(doctor.initials)"),
            methods: paymentMethods,
            createdBy: producer.asAnyUser
        )
    }

    func makeRefundPayment(refund: Refund, paymentType: PaymentType, includeBalance: Bool) -> Payment {
        let patient = refund.check?.appointments?.first?.patient
        var purpose: Payment.Purpose = .refund(patient?.initials ?? "")
        let paymentValue = refund.totalAmount - (patient?.balance ?? 0)

        if includeBalance, patient?.balance != 0 {
            purpose.descripiton.append(" (Записано на баланс \(Int(-(patient?.balance ?? 0))) ₽)")
        }

        let refundMethod = Payment.Method(paymentType, value: paymentValue)

        return Payment(purpose: purpose, methods: [refundMethod], createdBy: producer.asAnyUser)
    }

    func makeBalancePayment(_ kind: UpdateBalanceKind, from person: AccountablePerson, method: Payment.Method) -> Payment {
        var description = person.initials

        if let doctor = person as? Doctor {
            description = "Врач: \(doctor.initials)"
        }

        var paymentMethod = method

        if kind == .payout {
            paymentMethod.value = -abs(method.value)
        }

        let purpose: Payment.Purpose = paymentMethod.value > 0 ? .toBalance(description) : .fromBalance(description)

        return Payment(purpose: purpose, methods: [paymentMethod], createdBy: producer.asAnyUser)
    }

    func makeSpendingPayment(purpose: Payment.Purpose, method: Payment.Method) -> Payment {
        var method = method
        method.value = -abs(method.value)
        return Payment(purpose: purpose, methods: [method], createdBy: producer.asAnyUser)
    }
}

// MARK: - PaymentFactory.Sample

extension PaymentFactory {
    enum Sample {
        case medicalService(check: Check, methods: [Payment.Method])
        case doctorPayout(Doctor, methods: [Payment.Method])
        case refund(Refund, paymentType: PaymentType, includeBalance: Bool)
        case balance(UpdateBalanceKind, person: AccountablePerson, method: Payment.Method)
        case spending(purpose: Payment.Purpose, method: Payment.Method)
    }
}
