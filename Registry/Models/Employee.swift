//
//  Employee.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

public protocol Employee: Person {
    var salary: Salary { get set }
    var agentFee: Double { get set }
}

public struct AnyEmployee: Employee, Codable, Hashable, Identifiable {
    public let id: UUID
    public var secondName: String
    public var firstName: String
    public var patronymicName: String
    public var phoneNumber: String
    public var balance: Double
    public var salary: Salary
    public var agentFee: Double
}
