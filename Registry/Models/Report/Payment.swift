//
//  Payment.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation

public struct Payment: Codable, Hashable, Identifiable {
    public let id: UUID
    public let date: Date
    public let purpose: Payment.Purpose
    public private(set) var methods: [Payment.Method]
    public var subject: Payment.Subject?
    public let createdBy: AnyUser

    public init(
        id: UUID = UUID(),
        purpose: Payment.Purpose,
        methods: [Payment.Method],
        subject: Payment.Subject? = nil,
        createdBy: AnyUser
    ) {
        self.id = id
        self.date = .now
        self.purpose = purpose
        self.methods = methods
        self.subject = subject
        self.createdBy = createdBy
    }

    public var totalAmount: Double {
        methods.reduce(0.0) { $0 + $1.value }
    }

    public mutating func updateMethodType(on type: PaymentType) {
        guard methods.count == 1,
              var method = methods.first else { return }

        method.type = type
        methods = [method]
    }
}
