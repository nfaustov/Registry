//
//  Ledger+Payments.swift
//  Registry
//
//  Created by Николай Фаустов on 23.05.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func makePayment(_ sample: PaymentFactory.Sample, createdBy user: User) {
        let factory = PaymentFactory(producer: user)
        let payment = factory.make(from: sample)

        proceedPayment(payment, as: sample)
    }

    private func proceedPayment(_ payment: Payment, as sample: PaymentFactory.Sample) {
        switch sample {
        case .medicalService(let patient, _, _):
            medicalServicePayment(payment, patient: patient)
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

    private func medicalServicePayment(_ payment: Payment, patient: Patient) {
        guard let check = payment.subject else { return }

        let paymentValue = payment.methods.reduce(0.0) { $0 + $1.value }
        let paymentBalance = paymentValue - check.totalPrice

        if paymentBalance != 0 {
            updateBalanceWithoutRecord(person: patient, increment: paymentBalance, createdBy: payment.createdBy)
        }

        patient.assignTransaction(payment)
        check.makeChargesForServices()
        check.appointments?.forEach { $0.status = .completed }
        distributePaymentforAccounts([.bank, .card], payment: payment, purpose: .income)
        record(payment)
    }

    private func doctorPayoutPayment(_ payment: Payment, for doctor: Doctor) {
        let paymentValue = payment.methods.reduce(0.0) { $0 + $1.value }
        doctor.assignTransaction(payment)
        doctor.updateBalance(increment: paymentValue)
        distributePaymentforAccounts(payment: payment, purpose: .salary)
        record(payment)
    }

    private func refundPayment(_ payment: Payment, refund: Refund, includeBalance: Bool) {
        guard let patient = refund.check?.appointments?.first?.patient else { return }

        if includeBalance, patient.balance != 0 {
            updateBalanceWithoutRecord(person: patient, increment: -patient.balance, createdBy: payment.createdBy)
        }

        patient.assignTransaction(payment)
        distributePaymentforAccounts(payment: payment, purpose: .refund)
        record(payment)
    }

    private func balancePayment(_ payment: Payment, for person: AccountablePerson) {
        let paymentValue = payment.methods.reduce(0.0) { $0 + $1.value }
        person.assignTransaction(payment)
        person.updateBalance(increment: paymentValue)
        record(payment)
    }

    private func spendingPayment(_ payment: Payment) {
        switch payment.purpose {
        case .collection:
            distributePaymentforAccounts([.cash], payment: payment, purpose: .transferFrom, detail: "Касса")
        case .equipment:
            distributePaymentforAccounts(payment: payment, purpose: .equipment, detail: payment.details)
        case .consumables:
            distributePaymentforAccounts(payment: payment, purpose: .consumables, detail: payment.details)
        case .building:
            distributePaymentforAccounts(payment: payment, purpose: .building, detail: payment.details)
        default: break
        }

        record(payment)
    }

    private func record(_ payment: Payment) {
        if let todayReport = getReport() {
            todayReport.makePayment(payment)
        } else {
            createReport(with: payment)
        }
    }

    private func updateBalanceWithoutRecord(person: AccountablePerson, increment: Double, createdBy user: User) {
        let balancePayment = Payment(
            purpose: .toBalance,
            details: person.initials,
            methods: [.init(.cash, value: increment)],
            createdBy: user.asAnyUser
        )
        person.updateBalance(increment: increment)
        person.assignTransaction(balancePayment)
    }

    private func checkingAccount(ofType type: AccountType) -> CheckingAccount? {
        let predicate = #Predicate<CheckingAccount> { $0.type == type }
        var descriptor = FetchDescriptor<CheckingAccount>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        if let account = try? modelContext.fetch(descriptor).first {
            return account
        } else { return nil }
    }

    private func distributePaymentforAccounts(
        _ accounts: [AccountType] = AccountType.allCases,
        payment: Payment,
        purpose: AccountTransaction.Purpose,
        detail: String? = nil
    ) {
        for method in payment.methods {
            let accountType = AccountType.correlatedAccount(with: method.type)

            if accounts.contains(accountType), let account = checkingAccount(ofType: accountType) {
                let transaction = AccountTransaction(purpose: purpose, detail: detail, amount: method.value)
                account.assignTransaction(transaction)
            }
        }
    }
}
