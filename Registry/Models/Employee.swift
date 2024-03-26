//
//  Employee.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

public protocol Employee: Person {
    var salary: Salary { get set }
    var agentFee: Double { get }
}

public struct AnyEmployee: Employee, Codable, Hashable, Identifiable {
    public let id: UUID
    public var secondName: String
    public var firstName: String
    public var patronymicName: String
    public var phoneNumber: String
    public private(set) var balance: Double
    public var salary: Salary
    public private(set) var agentFee: Double
}

public extension Employee {
    var employee: AnyEmployee {
        AnyEmployee(
            id: id,
            secondName: secondName,
            firstName: firstName,
            patronymicName: patronymicName,
            phoneNumber: phoneNumber,
            balance: balance,
            salary: salary,
            agentFee: agentFee
        )
    }
}
