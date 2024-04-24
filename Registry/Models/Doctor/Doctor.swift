//
//  Doctor.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import Foundation
import SwiftData

@Model
final class Doctor: Employee, User, Codable {
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
    private(set) var agentFee: Double = 0
    private(set) var agentFeePaymentDate: Date = Date.now
    private(set) var balance: Double = 0
    var info: String = ""
    let createdAt: Date = Date.now
    @Attribute(.externalStorage)
    var image: Data?
    var accessLevel: UserAccessLevel = UserAccessLevel.doctor

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
        self.defaultPricelistItem = defaultPricelistItem
        self.serviceDuration = serviceDuration
        self.defaultCabinet = defaultCabinet
        self.doctorSalary = doctorSalary
        self.agentFee = agentFee
        self.agentFeePaymentDate = agentFeePaymentDate
        self.balance = balance
        self.info = info
        self.createdAt = .now
        self.image = image
        self.accessLevel = accessLevel
    }

    func updateBalance(increment: Double) {
        balance += increment
    }

    func performedServices(from date: Date) -> [MedicalService] {
        performedServices?
            .filter { service in
                if let serviceDate = service.date {
                    return serviceDate > date
                } else { return false }
            } ?? []
    }

    func charge(as role: KeyPath<MedicalService, Doctor?>, amount: Double) {
        switch role {
        case \.performer:
            balance += amount
        case \.agent:
            agentFee += amount
        default: ()
        }
    }

    func agentFeePayment(value: Double) {
        guard value >= agentFee else { return }

        let diff = value - agentFee
        agentFee = 0
        balance += diff
        agentFeePaymentDate = .now
    }

    func pieceRateSalary(for services: [MedicalService]) -> Double {
        switch doctorSalary {
        case .pieceRate(let rate, let minAmount):
            let salary = services
                .reduce(0.0) { partialResult, service in
                    if service.refund == nil, service.performer == self {
                        if service.pricelistItem.category == Department.laboratory {
                            return partialResult + 0
                        } else if let fixedSalaryAmount = service.pricelistItem.fixedSalary {
                            return partialResult + fixedSalaryAmount
                        } else {
                            return partialResult + service.pricelistItem.price * rate
                        }
                    } else {
                        return partialResult + 0
                    }
                }

            return max(minAmount ?? 0, salary)
        default: return 0
        }
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
        self.agentFee = try container.decode(Double.self, forKey: .agentFee)
        self.agentFeePaymentDate = try container.decode(Date.self, forKey: .agentFeePaymentDate)
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
        try container.encode(agentFee, forKey: .agentFee)
        try container.encode(agentFeePaymentDate, forKey: .agentFeePaymentDate)
        try container.encode(balance, forKey: .balance)
        try container.encode(info, forKey: .info)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(accessLevel, forKey: .accessLevel)
    }
}
