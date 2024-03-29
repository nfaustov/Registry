//
//  Doctor.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation
import SwiftData

@Model
public final class Doctor: Employee, User {
    public let id: UUID = UUID()
    public var secondName: String = ""
    public var firstName: String = ""
    public var patronymicName: String = ""
    public var phoneNumber: String = ""
    public var birthDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    public var department: Department = Department.gynecology
    public var basicService: PricelistItem.Short?
    public var serviceDuration: TimeInterval = 600
    public var defaultCabinet: Int = 1
    public var salary: Salary = Salary.pieceRate(rate: 0.4)
    public private(set) var agentFee: Double = 0
    public private(set) var agentFeePaymentDate: Date = Date.now
    public private(set) var balance: Double = 0
    public var info: String = ""
    public let createdAt: Date = Date.now
    @Attribute(.externalStorage)
    public var image: Data?
    public var accessLevel: UserAccessLevel = UserAccessLevel.doctor
    public var schedules: [DoctorSchedule]?

    
    public init(
        id: UUID = UUID(),
        secondName: String,
        firstName: String,
        patronymicName: String,
        phoneNumber: String,
        birthDate: Date,
        department: Department,
        basicService: PricelistItem.Short?,
        serviceDuration: TimeInterval,
        defaultCabinet: Int,
        salary: Salary,
        agentFee: Double = 0,
        agentFeePaymentDate: Date = .now,
        balance: Double = 0,
        info: String = "",
        image: Data? = nil,
        accessLevel: UserAccessLevel = .doctor
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
        self.agentFeePaymentDate = agentFeePaymentDate
        self.balance = balance
        self.info = info
        self.createdAt = .now
        self.image = image
        self.accessLevel = accessLevel
    }

    public func charge(as role: KeyPath<RenderedService, AnyEmployee?>, amount: Double) {
        switch role {
        case \.performer:
            balance += amount
        case \.agent:
            agentFee += amount
        default: ()
        }
    }

    public func agentFeePayment() {
        balance += agentFee
        agentFee = 0
        agentFeePaymentDate = .now
    }
}
