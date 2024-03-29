//
//  Report.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

@Model
public final class Report {
    public let id: UUID = UUID()
    public let date: Date = Date.now
    public let startingCash: Double = Double.zero
    public var payments: [Payment] = []

    public init(
        id: UUID = UUID(),
        date: Date,
        startingCash: Double,
        payments: [Payment]
    ) {
        self.id = id
        self.date = date
        self.startingCash = startingCash
        self.payments = payments
    }

    public var cashBalance: Double {
        startingCash + reporting(.profit, of: .cash) + collected
    }

    public var collected: Double {
        payments
            .filter { $0.purpose == .collection }
            .flatMap { $0.methods }
            .reduce(0.0) { $0 + $1.value }
    }

    public func reporting(_ reporting: Reporting, of type: PaymentType? = nil) -> Double {
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

    public func fraction(_ kind: Reporting, ofAccount type: PaymentType) -> Double {
        guard reporting(kind) != 0 else { return 0 }
        return reporting(kind, of: type) / reporting(kind)
    }
}

// MARK: - Private methods

private extension Report {
    func paymentMethods(ofType type: PaymentType?) -> [Payment.Method] {
        let methods = payments
            .filter { $0.purpose != .collection }
            .flatMap { $0.methods }

        if let type { return methods.filter { $0.type == type } }

        return methods
    }
}

// MARK: - Reporting

public enum Reporting: String, Hashable, Identifiable, CaseIterable {
    case profit = "Баланс"
    case income = "Доходы"
    case expense = "Расходы"

    public var id: Self {
        self
    }
}

// MARK: - Salary calculation

public extension Report {
    func renderedServices(by employee: Employee, role: KeyPath<RenderedService, AnyEmployee?>) -> [RenderedService] {
        payments
            .compactMap { $0.subject }
            .filter { !$0.isRefund }
            .flatMap { $0.services }
            .filter { $0[keyPath: role]?.id == employee.id }
    }

    func daySalary(of employee: Employee) -> Double {
        switch employee.salary {
        case .pieceRate(let rate):
            return renderedServices(by: employee, role: \.performer)
                .reduce(0.0) { partialResult, service in
                    if let fixedSalaryAmount = service.pricelistItem.salaryAmount {
                        partialResult + fixedSalaryAmount
                    } else {
                        partialResult + service.pricelistItem.price * rate
                    }
                }
        default: return 0
        }
    }
}
