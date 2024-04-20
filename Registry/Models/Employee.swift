//
//  Employee.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

extension RegistrySchemaV1 {
    protocol Employee: Person {
        var salary: Salary { get set }
        var agentFee: Double { get }
    }
}

extension RegistrySchemaV1 {
    struct AnyEmployee: Employee, Codable, Hashable, Identifiable {
        let id: UUID
        var secondName: String
        var firstName: String
        var patronymicName: String
        var phoneNumber: String
        var balance: Double
        var salary: Salary
        private(set) var agentFee: Double
        var image: Data?
    }
}

extension RegistrySchemaV1.Employee {
    var employee: RegistrySchemaV1.AnyEmployee {
        RegistrySchemaV1.AnyEmployee(
            id: id,
            secondName: secondName,
            firstName: firstName,
            patronymicName: patronymicName,
            phoneNumber: phoneNumber,
            balance: balance,
            salary: salary,
            agentFee: agentFee,
            image: image
        )
    }
}

extension RegistrySchemaV3 {
    protocol Employee: Person {
        var doctorSalary: Salary { get set }
        var agentFee: Double { get }
    }
}
