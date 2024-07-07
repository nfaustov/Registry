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
    let purpose: PaymentPurpose?
    let details: String = ""
    private(set) var methods: [Payment.Method] = [Payment.Method(.cash, value: 0)]
    @Relationship(deleteRule: .cascade, inverse: \Check.payment)
    var subject: Check?
    let createdBy: AnyUser = AnonymousUser().asAnyUser

    var report: Report?
    var doctor: Doctor?
    var patient: Patient?

    init(
        purpose: PaymentPurpose,
        details: String,
        methods: [Payment.Method],
        subject: Check? = nil,
        createdBy: AnyUser
    ) {
        date = .now
        self.purpose = purpose
        self.details = details
        self.methods = methods
        self.subject = subject
        self.createdBy = createdBy
    }

    var totalAmount: Double {
        methods.reduce(0.0) { $0 + $1.value }
    }

    func updateMethod(withType type: PaymentType, on newType: PaymentType) {
        guard let updateMethodIndex = methods.firstIndex(where: { $0.type == type }) else { return }

        var updatedMethod = methods.remove(at: updateMethodIndex)
        updatedMethod.type = newType
        methods.insert(updatedMethod, at: updateMethodIndex)
    }
}
