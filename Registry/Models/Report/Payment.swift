//
//  Payment.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

extension RegistrySchemaV1 {
    struct Payment: Codable, Hashable, Identifiable {
        let id: UUID
        let date: Date
        let purpose: RegistrySchemaV3.Payment.Purpose
        private(set) var methods: [RegistrySchemaV3.Payment.Method]
        var subject: RegistrySchemaV1.Payment.Subject?
        let createdBy: AnyUser

        init(
            id: UUID = UUID(),
            purpose: RegistrySchemaV3.Payment.Purpose,
            methods: [RegistrySchemaV3.Payment.Method],
            subject: RegistrySchemaV1.Payment.Subject? = nil,
            createdBy: AnyUser
        ) {
            self.id = id
            self.date = .now
            self.purpose = purpose
            self.methods = methods
            self.subject = subject
            self.createdBy = createdBy
        }

        var totalAmount: Double {
            methods.reduce(0.0) { $0 + $1.value }
        }

        mutating func updateMethodType(on type: PaymentType) {
            guard methods.count == 1,
                  var method = methods.first else { return }

            method.type = type
            methods = [method]
        }
    }
}

extension RegistrySchemaV2 {
    @Model
    final class Payment {
        let date: Date = Date.now
        let purpose: RegistrySchemaV3.Payment.Purpose = RegistrySchemaV3.Payment.Purpose.collection
        private(set) var methods: [RegistrySchemaV3.Payment.Method] = [RegistrySchemaV3.Payment.Method(.cash, value: 0)]
        @Relationship(inverse: \Check.payment)
        var subject: Check?
        let createdBy: AnyUser = AnonymousUser().asAnyUser

        var report: Report?

        init(
            purpose: RegistrySchemaV3.Payment.Purpose,
            methods: [RegistrySchemaV3.Payment.Method],
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
}

extension RegistrySchemaV3 {
    @Model
    final class Payment {
        let date: Date = Date.now
        let purpose: Payment.Purpose = Payment.Purpose.collection
        private(set) var methods: [Payment.Method] = [Payment.Method(.cash, value: 0)]
        @Relationship(inverse: \Check.payment)
        var subject: Check?
        let createdBy: AnyUser = AnonymousUser().asAnyUser

        var report: Report?

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
}
