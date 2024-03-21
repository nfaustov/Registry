//
//  Visit.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

public struct Visit: Codable, Hashable, Identifiable {
    public let id: UUID
    public let registrationDate: Date
    public let registrar: AnyUser
    public let visitDate: Date
    public var cancellationDate: Date?
    public var bill: Bill?
    public var refund: Refund?

    public init(
        id: UUID = UUID(),
        registrar: AnyUser,
        visitDate: Date,
        cancellationDate: Date? = nil,
        bill: Bill? = nil,
        refund: Refund? = nil
    ) {
        self.id = id
        self.registrationDate = .now
        self.registrar = registrar
        self.visitDate = visitDate
        self.cancellationDate = cancellationDate
        self.bill = bill
        self.refund = refund
    }
}
