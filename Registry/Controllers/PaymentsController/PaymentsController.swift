//
//  PaymentsController.swift
//  Registry
//
//  Created by Николай Фаустов on 22.05.2024.
//

import Foundation
import SwiftData

@MainActor
final class PaymentsController {
    let report: Report

    init(report: Report) {
        self.report = report
    }

    func makePayment(_ sample: PaymentFactory.Sample, createdBy user: User) {
        let factory = PaymentFactory(producer: user)
        let payment = factory.make(from: sample)

        proceedPayment(payment, as: sample)
    }
}

private extension PaymentsController {
    func proceedPayment(_ payment: Payment, as sample: PaymentFactory.Sample) {
        switch sample {
        case .medicalService:
            medicalServicePayment(payment)
        case .doctorPayout(let doctor, _):
            doctorPayoutPayment(payment, for: doctor)
        case .refund(let refund, _, let includeBalance):
            refundPayment(payment, refund: refund, includeBalance: includeBalance)
        case .balance(_, let person, _):
            balancePayment(payment, for: person)
        case .spending:
            spendingPayment(payment)
        }
    }

    func medicalServicePayment(_ payment: Payment) {
        guard let check = payment.subject,
              let patient = check.appointments?.first?.patient else { return }

        let paymentValue = payment.methods.reduce(0.0) { $0 + $1.value }
        let paymentBalance = paymentValue - check.totalPrice

        if paymentBalance != 0 {
            updateBalanceWithoutRecord(person: patient, increment: paymentBalance, createdBy: payment.createdBy)
        }

        patient.assignTransaction(payment)
        check.makeChargesForServices()
        check.appointments?.forEach { $0.status = .completed }
        report.makePayment(payment)
    }

    func doctorPayoutPayment(_ payment: Payment, for doctor: Doctor) {
        let paymentValue = payment.methods.reduce(0.0) { $0 + $1.value }
        doctor.assignTransaction(payment)
        doctor.updateBalance(increment: paymentValue)
        report.makePayment(payment)
    }

    func refundPayment(_ payment: Payment, refund: Refund, includeBalance: Bool) {
        guard let patient = refund.check?.appointments?.first?.patient else { return }

        if includeBalance, patient.balance != 0 {
            updateBalanceWithoutRecord(person: patient, increment: -patient.balance, createdBy: payment.createdBy)
        }

        patient.assignTransaction(payment)
        report.makePayment(payment)
    }

    func balancePayment(_ payment: Payment, for person: AccountablePerson) {
        guard let paymentMethod = payment.methods.first else { return }

        person.assignTransaction(payment)
        person.updateBalance(increment: paymentMethod.value)
        report.makePayment(payment)
    }

    func spendingPayment(_ payment: Payment) {
        report.makePayment(payment)
    }

    func updateBalanceWithoutRecord(person: AccountablePerson, increment: Double, createdBy user: User) {
        let balancePayment = Payment(purpose: .toBalance(person.initials), methods: [.init(.cash, value: increment)], createdBy: user.asAnyUser)
        person.updateBalance(increment: increment)
        person.assignTransaction(balancePayment)
    }
}
