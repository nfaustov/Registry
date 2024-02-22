//
//  Payment.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation

public struct Payment: Codable, Hashable, Identifiable {
    public var id: UUID
    public var date: Date
    public var purpose: Payment.Purpose
    public var methods: [Payment.Method]
    public var bill: Bill?

    public init(
        id: UUID = UUID(),
        purpose: Payment.Purpose,
        methods: [Payment.Method],
        bill: Bill? = nil
    ) {
        self.id = id
        self.date = .now
        self.purpose = purpose
        self.methods = methods
        self.bill = bill
    }

    public var totalAmount: Double {
        methods.reduce(0.0) { $0 + $1.value }
    }
}
