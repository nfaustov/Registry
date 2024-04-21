//
//  Employee.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

protocol Employee: AccountablePerson {
    var doctorSalary: Salary { get set }
    var agentFee: Double { get }
}
