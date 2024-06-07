//
//  Report+Reporting.swift
//  Registry
//
//  Created by Николай Фаустов on 06.06.2024.
//

import Foundation

extension Report {
    var cashBalance: Double {
        startingCash + reporting(.profit, of: .cash) + collected
    }

    var collected: Double {
        payments?
            .filter { $0.purpose == .collection }
            .flatMap { $0.methods }
            .reduce(0.0) { $0 + $1.value } ?? 0
    }

    func billsIncome(of type: PaymentType? = nil) -> Double {
        let methods = payments?
            .filter { $0.subject != nil }
            .flatMap { $0.methods } ?? []

        if let type {
            return methods
                .filter { $0.type == type }
                .reduce(0.0) { $0 + $1.value }
        } else {
            return methods.reduce(0.0) { $0 + $1.value }
        }
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

