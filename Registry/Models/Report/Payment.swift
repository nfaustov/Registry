//
//  Payment.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

@Model
final class Payment {
    let date: Date = Date.now
    var purpose: Payment.Purpose = Payment.Purpose.collection
    private(set) var methods: [Payment.Method] = [Payment.Method(.cash, value: 0)]
    @Relationship(inverse: \Check.payment)
    var subject: Check?
    let createdBy: AnyUser = AnonymousUser().asAnyUser

    var report: Report?
    var doctor: Doctor?
    var patient: Patient?

    init(
        purpose: Payment.Purpose,
        methods: [Payment.Method],
        subject: Check? = nil,
        createdBy: AnyUser
    ) {
        date = .now
        self.purpose = purpose
        self.methods = methods
        self.subject = subject
        self.createdBy = createdBy
        self.report = report
    }

    var totalAmount: Double {
        methods.reduce(0.0) { $0 + $1.value }
    }

    func updateMethodType(on type: PaymentType) {
        guard methods.count == 1,
              var method = methods.first else { return }

        method.type = type
        methods = [method]
    }
}
