//
//  PaymentFactory.swift
//  Registry
//
//  Created by Николай Фаустов on 22.05.2024.
//

import Foundation

struct PaymentFactory {
    let producer: User

    init(producer: User) {
        self.producer = producer
    }

    func make(from sample: PaymentFactory.Sample) -> Payment {
        switch sample {
        case .medicalService(let patient, let check, let methods):
            makeMedicalServicePayment(from: patient, check: check, methods: methods)
        case .doctorPayout(let doctor, let methods):
            makeDoctorPayoutPayment(doctor: doctor, methods: methods)
        case .refund(let refund, let paymentType, let includeBalance):
            makeRefundPayment(refund: refund, paymentType: paymentType, includeBalance: includeBalance)
        case .balance(let kind, let person, let method):
            makeBalancePayment(kind, from: person, method: method)
        case .spending(let purpose, let details, let method):
            makeSpendingPayment(purpose: purpose, details: details, method: method)
        }
    }
}

// MARK: - Private methods

private extension PaymentFactory {
    func makeMedicalServicePayment(from patient: Patient, check: Check, methods: [Payment.Method]) -> Payment {
        let paymentValue = methods.reduce(0.0) { $0 + $1.value }
        let paymentBalance = paymentValue - check.totalPrice
        var details = patient.initials

        if paymentBalance != 0 {
            details.append(" (Записано на баланс \(Int(paymentBalance)) ₽)")
        }

        return Payment(
            purpose: .medicalServices,
            details: details,
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
            purpose: .doctorPayout,
            details: "Врач: \(doctor.initials)",
            methods: paymentMethods,
            createdBy: producer.asAnyUser
        )
    }

    func makeRefundPayment(refund: Refund, paymentType: PaymentType, includeBalance: Bool) -> Payment {
        let patient = refund.check?.appointments?.first?.patient
        var details = patient?.initials ?? ""
        let paymentValue = refund.totalAmount - (patient?.balance ?? 0)

        if includeBalance, patient?.balance != 0 {
            details.append(" (Записано на баланс \(Int(-(patient?.balance ?? 0))) ₽)")
        }

        let refundMethod = Payment.Method(paymentType, value: paymentValue)

        return Payment(
            purpose: .refund,
            details: details,
            methods: [refundMethod],
            createdBy: producer.asAnyUser
        )
    }

    func makeBalancePayment(_ kind: UpdateBalanceKind, from person: AccountablePerson, method: Payment.Method) -> Payment {
        var details = person.initials

        if let doctor = person as? Doctor {
            details = "Врач: \(doctor.initials)"
        }

        var paymentMethod = method

        if kind == .payout {
            paymentMethod.value = -abs(method.value)
        }

        let purpose: PaymentPurpose = paymentMethod.value > 0 ? .toBalance : .fromBalance

        return Payment(
            purpose: purpose,
            details: details,
            methods: [paymentMethod],
            createdBy: producer.asAnyUser
        )
    }

    func makeSpendingPayment(purpose: PaymentPurpose, details: String, method: Payment.Method) -> Payment {
        let paymentMethod = Payment.Method(method.type, value: -abs(method.value))
        return Payment(purpose: purpose, details: details, methods: [paymentMethod], createdBy: producer.asAnyUser)
    }
}

// MARK: - PaymentFactory.Sample

extension PaymentFactory {
    enum Sample {
        case medicalService(patient: Patient, check: Check, methods: [Payment.Method])
        case doctorPayout(Doctor, methods: [Payment.Method])
        case refund(Refund, paymentType: PaymentType, includeBalance: Bool)
        case balance(UpdateBalanceKind, person: AccountablePerson, method: Payment.Method)
        case spending(purpose: PaymentPurpose, details: String, method: Payment.Method)
    }
}
