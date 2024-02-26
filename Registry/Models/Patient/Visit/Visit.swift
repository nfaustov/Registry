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
    public let visitDate: Date
    public let destination: Department
    public var cancellationDate: Date?
    public var bill: Bill?
    public var isRefund: Bool

    public init(
        id: UUID = UUID(),
        visitDate: Date,
        destination: Department,
        cancellationDate: Date? = nil,
        bill: Bill? = nil,
        isRefund: Bool = false
    ) {
        self.id = id
        self.registrationDate = .now
        self.visitDate = visitDate
        self.destination = destination
        self.cancellationDate = cancellationDate
        self.bill = bill
        self.isRefund = isRefund
    }
}
