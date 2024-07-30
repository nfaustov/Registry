//
//  Ledger+Payments.swift
//  Registry
//
//  Created by Николай Фаустов on 23.05.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func makePayment(_ sample: PaymentFactory.Sample, createdBy user: User) throws {
        let factory = PaymentFactory(producer: user)
        let payment = factory.make(from: sample)

        try proceedPayment(payment, as: sample)
    }

    func cancelPayment(payment: Payment) {
        guard let report = getReport() else { return }

        if payment.purpose == .collection, let account = checkingAccount(ofType: .cash) {
            guard let transaction = account.transactions
                .filter({ Calendar.current.isDate($0.date, inSameDayAs: payment.date) })
                .first(where: { $0.purpose == .transferFrom && $0.amount == -payment.totalAmount }) else { return }

            account.removeTransaction(transaction)
        } else if payment.purpose == .medicalServices,
            let check = payment.subject,
            let patient = payment.patient {
            let paymentBalance = payment.totalAmount - check.totalPrice

            if paymentBalance != 0 {
                patient.cancelTransaction(where: {
                    Calendar.current.isDateInToday($0.date) && $0.totalAmount == paymentBalance
                })
                patient.updateBalance(increment: -paymentBalance)
            }

            patient.cancelTransaction(where: { $0 == payment })
            check.cancelChargesForServices()
            check.appointments?.forEach { $0.status = .came }
            database.modelContext.delete(payment)
        }

        report.cancelPayment(payment.id)
    }

    private func proceedPayment(_ payment: Payment, as sample: PaymentFactory.Sample) throws {
        switch sample {
        case .medicalService(let person, _, _):
            try medicalServicePayment(payment, person: person)
        case .doctorPayout(let doctor, _):
            try doctorPayoutPayment(payment, for: doctor)
        case .refund(let refund, _, let includeBalance):
            try refundPayment(payment, refund: refund, includeBalance: includeBalance)
        case .balance(_, let person, _):
            try balancePayment(payment, for: person)
        case .spending:
            try spendingPayment(payment)
        }
    }

    private func medicalServicePayment(_ payment: Payment, person: AccountablePerson) throws {
        guard let check = payment.subject else { return }

        let paymentBalance = payment.totalAmount - check.totalPrice

        try record(payment)

        if paymentBalance != 0 {
            updateBalanceWithoutRecord(person: person, increment: paymentBalance, createdBy: payment.createdBy)
        }

        person.assignTransaction(payment)
        check.makeChargesForServices()
        check.appointments?.forEach { $0.status = .completed }
    }

    private func doctorPayoutPayment(_ payment: Payment, for doctor: Doctor) throws {
        try record(payment)
        doctor.assignTransaction(payment)
        doctor.updateBalance(increment: payment.totalAmount)
    }

    private func refundPayment(_ payment: Payment, refund: Refund, includeBalance: Bool) throws {
        guard let patient = refund.check?.appointments?.first?.patient else { return }

        try record(payment)

        if includeBalance, patient.balance != 0 {
            updateBalanceWithoutRecord(person: patient, increment: -patient.balance, createdBy: payment.createdBy)
        }

        patient.assignTransaction(payment)
    }

    private func balancePayment(_ payment: Payment, for person: AccountablePerson) throws {
        try record(payment)
        person.assignTransaction(payment)
        person.updateBalance(increment: payment.totalAmount, allRoles: true)
    }

    private func spendingPayment(_ payment: Payment) throws {
        try record(payment)

        if payment.purpose == .collection {
            let transaction = AccountTransaction(
                purpose: .transferFrom,
                detail: "Касса",
                amount: -payment.totalAmount
            )

            guard let account: CheckingAccount = database.getModels().first(where: { $0.type == .cash }) else { return }

            account.assignTransaction(transaction)
        }
    }

    private func record(_ payment: Payment) throws {
        if let todayReport = getReport() {
            if !todayReport.closed {
                todayReport.makePayment(payment)
            } else {
                throw RegistryError.closedReport
            }
        } else {
            createReport(with: payment)
        }
    }

    private func updateBalanceWithoutRecord(person: AccountablePerson, increment: Double, createdBy user: User) {
        let balancePayment = Payment(
            purpose: increment < 0 ? .fromBalance : .toBalance,
            details: person.initials,
            methods: [.init(.cash, value: increment)],
            createdBy: user.asAnyUser
        )
        person.updateBalance(increment: increment, allRoles: true)
        person.assignTransaction(balancePayment)
    }
}
