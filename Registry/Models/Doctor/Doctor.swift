//
//  Doctor.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation
import SwiftData

@Model
public final class Doctor: Employee {
    public let id: UUID = UUID()
    public var secondName: String = ""
    public var firstName: String = ""
    public var patronymicName: String = ""
    public var phoneNumber: String = ""
    public var birthDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    public var department: Department = Department.gynecology
    public var basicService: PricelistItem?
    public var serviceDuration: TimeInterval = 600
    public var defaultCabinet: Int = 1
    public var salary: Salary = Salary.pieceRate(rate: 0.4)
    public var agentFee: Double = 0
    public var balance: Double = 0
    public var info: String = ""
    public var createdAt: Date = Date.now
    @Attribute(.externalStorage)
    public var image: Data?
    
    public init(
        id: UUID = UUID(),
        secondName: String,
        firstName: String,
        patronymicName: String,
        phoneNumber: String,
        birthDate: Date,
        department: Department,
        basicService: PricelistItem?,
        serviceDuration: TimeInterval,
        defaultCabinet: Int,
        salary: Salary,
        agentFee: Double = 0,
        balance: Double = 0,
        info: String = "",
        image: Data? = nil
    ) {
        self.id = id
        self.secondName = secondName
        self.firstName = firstName
        self.patronymicName = patronymicName
        self.phoneNumber = phoneNumber
        self.birthDate = birthDate
        self.department = department
        self.basicService = basicService
        self.serviceDuration = serviceDuration
        self.defaultCabinet = defaultCabinet
        self.salary = salary
        self.agentFee = agentFee
        self.balance = balance
        self.info = info
        self.createdAt = .now
        self.image = image
    }

    public var employee: AnyEmployee {
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
