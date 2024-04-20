//
//  Report.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

@Model
final class Report {
    let date: Date = Date.now
    let startingCash: Double = Double.zero
    @Relationship(deleteRule: .cascade, inverse: \Payment.report)
    private(set) var payments: [Payment]?

    init(
        date: Date,
        startingCash: Double,
        payments: [Payment]? = []
    ) {
        self.date = date
        self.startingCash = startingCash
        self.payments = payments
    }

    var cashBalance: Double {
        startingCash + reporting(.profit, of: .cash) + collected
    }

    var collected: Double {
        payments?
            .filter { $0.purpose == .collection }
            .flatMap { $0.methods }
            .reduce(0.0) { $0 + $1.value } ?? 0
    }

    var hasBillIncome: Bool {
        guard let payments else { return false}

        return !payments
            .compactMap { $0.subject }
            .isEmpty
    }

    var hasOtherIncome: Bool {
        guard let payments else { return false}

        return !payments
            .filter { $0.subject == nil }
            .flatMap { $0.methods }
            .filter { $0.value > 0 }
            .isEmpty
    }

    var hasExpense: Bool {
        guard let payments else { return false}

        return !payments
            .filter { $0.subject == nil }
            .filter { $0.purpose != .collection }
            .flatMap { $0.methods }
            .filter { $0.value < 0 }
            .isEmpty
    }

    func billsIncome(of type: PaymentType) -> Double {
        payments?
            .filter { $0.subject != nil }
            .flatMap { $0.methods }
            .filter { $0.type == type }
            .reduce(0.0) { $0 + $1.value } ?? 0
    }

    func payment(_ payment: Payment) {
        payments?.append(payment)
    }

    func cancelPayment(_ paymentID: PersistentIdentifier) {
        payments?.removeAll(where: { $0.id == paymentID })
    }

    func othersIncome(of type: PaymentType? = nil) -> Double {
        let methods = payments?
            .filter { $0.subject == nil }
            .flatMap { $0.methods }
            .filter { $0.value > 0 } ?? []

        if let type {
            return methods
                .filter { $0.type == type }
                .reduce(0.0) { $0 + $1.value }
        } else {
            return methods.reduce(0.0) { $0 + $1.value }
        }
    }

    func reporting(_ reporting: Reporting, of type: PaymentType? = nil) -> Double {
        switch reporting {
        case .profit:
            return paymentMethods(ofType: type).reduce(0.0) { $0 + $1.value }
        case .income:
            return paymentMethods(ofType: type)
                .filter { $0.value > 0 }
                .reduce(0.0) { $0 + $1.value }
        case .expense:
            return paymentMethods(ofType: type)
                .filter { $0.value < 0 }
                .reduce(0.0) { $0 + $1.value}
        }
    }

    func fraction(_ kind: Reporting, ofAccount type: PaymentType) -> Double {
        guard reporting(kind) != 0 else { return 0 }
        return reporting(kind, of: type) / reporting(kind)
    }

    func updatePayment(for updatedCheck: Check) {
        guard let payment = payments?.first(where: { payment in
            if let subject = payment.subject {
                return subject.id == updatedCheck.id
            } else { return false }
        }) else { return }

        payment.subject = updatedCheck
    }
}

// MARK: - Reporting

enum Reporting: String, Hashable, Identifiable, CaseIterable {
    case profit = "Баланс"
    case income = "Доходы"
    case expense = "Расходы"

    var id: Self {
        self
    }
}

// MARK: - Private methods

private extension Report {
    func paymentMethods(ofType type: PaymentType?) -> [Payment.Method] {
        let methods = payments?
            .filter { $0.purpose != .collection }
            .flatMap { $0.methods } ?? []

        if let type { return methods.filter { $0.type == type } }

        return methods
    }
}
