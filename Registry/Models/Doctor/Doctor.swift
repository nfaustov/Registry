//
//  Doctor.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation
import SwiftData

@Model
final class Doctor: Accountable, User, Codable {
    let id: UUID = UUID()
    var secondName: String = ""
    var firstName: String = ""
    var patronymicName: String = ""
    var phoneNumber: String = ""
    var birthDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    var department: Department = Department.gynecology
    @Relationship(inverse: \PricelistItem.doctors)
    var defaultPricelistItem: PricelistItem? = nil
    var serviceDuration: TimeInterval = 600
    var defaultCabinet: Int = 1
    var doctorSalary: Salary = Salary.pieceRate(rate: 0.4)
    private(set) var balance: Double = 0
    var info: String = ""
    let createdAt: Date = Date.now
    @Attribute(.externalStorage)
    var image: Data?
    var accessLevel: UserAccessLevel = UserAccessLevel.doctor
    var vacationSchedule: [DateInterval] = []
    @Relationship(inverse: \Payment.doctor)
    private(set) var transactions: [Payment]? = []

    var schedules: [DoctorSchedule]?
    var performedServices: [MedicalService]?
    var appointedServices: [MedicalService]?

    init(
        id: UUID = UUID(),
        secondName: String,
        firstName: String,
        patronymicName: String,
        phoneNumber: String,
        birthDate: Date,
        department: Department,
        defaultPricelistItem: PricelistItem? = nil,
        serviceDuration: TimeInterval,
        defaultCabinet: Int,
        doctorSalary: Salary,
        balance: Double = 0,
        info: String = "",
        image: Data? = nil,
        accessLevel: UserAccessLevel = .doctor,
        vacationSchedule: [DateInterval] = [],
        transactions: [Payment]? = []
    ) {
        self.id = id
        self.secondName = secondName
        self.firstName = firstName
        self.patronymicName = patronymicName
        self.phoneNumber = phoneNumber
        self.birthDate = birthDate
        self.department = department
        self.defaultPricelistItem = defaultPricelistItem
        self.serviceDuration = serviceDuration
        self.defaultCabinet = defaultCabinet
        self.doctorSalary = doctorSalary
        self.balance = balance
        self.info = info
        self.createdAt = .now
        self.image = image
        self.accessLevel = accessLevel
        self.vacationSchedule = vacationSchedule
        self.transactions = transactions
    }

    func updateBalance(increment: Double) {
        balance += increment
    }

    func assignTransaction(_ transaction: Payment) {
        transactions?.append(transaction)
    }

    func getTransactions(from date: Date) -> [DoctorMoneyTransaction] {
        var doctorTransactions = [DoctorMoneyTransaction]()

        if let rate = doctorSalary.rate {
            let performerTransactions = performedServices(from: date)
                .map { DoctorMoneyTransaction(medicalService: $0, doctorSalaryRate: rate) }
            doctorTransactions.append(contentsOf: performerTransactions)
        }

        let agentTransactions = appointedServices(from: date)
            .map { DoctorMoneyTransaction(medicalService: $0) }
        doctorTransactions.append(contentsOf: agentTransactions)

        if let transactions {
            let paymentTransactions = transactions.map { DoctorMoneyTransaction(payment: $0) }
            doctorTransactions.append(contentsOf: paymentTransactions)
        }

        return doctorTransactions
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id, secondName, firstName, patronymicName, phoneNUmber, birthDate, department, serviceDuration, defaultCabinet, doctorSalary, agentFee, agentFeePaymentDate, balance, info, createdAt, accessLevel
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.secondName = try container.decode(String.self, forKey: .secondName)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.patronymicName = try container.decode(String.self, forKey: .patronymicName)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNUmber)
        self.birthDate = try container.decode(Date.self, forKey: .birthDate)
        self.department = try container.decode(Department.self, forKey: .department)
        self.serviceDuration = try container.decode(TimeInterval.self, forKey: .serviceDuration)
        self.defaultCabinet = try container.decode(Int.self, forKey: .defaultCabinet)
        self.doctorSalary = try container.decode(Salary.self, forKey: .doctorSalary)
        self.balance = try container.decode(Double.self, forKey: .balance)
        self.info = try container.decode(String.self, forKey: .info)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.accessLevel = try container.decode(UserAccessLevel.self, forKey: .accessLevel)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(secondName, forKey: .secondName)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(patronymicName, forKey: .patronymicName)
        try container.encode(phoneNumber, forKey: .phoneNUmber)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(department, forKey: .department)
        try container.encode(serviceDuration, forKey: .serviceDuration)
        try container.encode(defaultCabinet, forKey: .defaultCabinet)
        try container.encode(doctorSalary, forKey: .doctorSalary)
        try container.encode(balance, forKey: .balance)
        try container.encode(info, forKey: .info)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(accessLevel, forKey: .accessLevel)
    }
}

// MARK: - Private extension

private extension Doctor {
    func appointedServices(from date: Date) -> [MedicalService] {
        appointedServices?.filter { service in
            if let serviceDate = service.date {
                return serviceDate > date
            } else { return false }
        } ?? []
    }

    func performedServices(from date: Date) -> [MedicalService] {
        performedServices?.filter { service in
            if let serviceDate = service.date {
                return serviceDate > date
            } else { return false }
        } ?? []
    }
}
