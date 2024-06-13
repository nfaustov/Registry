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

    func makePayment(_ payment: Payment) {
        payments?.append(payment)
    }

    func cancelPayment(_ paymentID: PersistentIdentifier) {
        payments?.removeAll(where: { $0.id == paymentID })
    }
}
