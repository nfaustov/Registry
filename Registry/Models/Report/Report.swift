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
    @Attribute(.unique)
    public var id: UUID
    public var date: Date = Date.now
    public var startingCash: Double = Double.zero
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
