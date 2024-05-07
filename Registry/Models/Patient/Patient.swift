//
//  Patient.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
final class Patient: AccountablePerson {
    let id: UUID = UUID()
    var secondName: String = ""
    var firstName: String =  ""
    var patronymicName: String = ""
    var phoneNumber: String = ""
    private(set) var balance: Double = Double.zero
    var passport: PassportData = PassportData()
    var placeOfResidence: PlaceOfResidence = PlaceOfResidence()
    var treatmentPlan: TreatmentPlan?
    let createdAt: Date = Date.now
    @Attribute(.externalStorage)
    var image: Data?
    @Relationship(inverse: \Payment.patient)
    var transactions: [Payment]? = []

    var appointments: [PatientAppointment]?

    init(
        id: UUID = UUID(),
        secondName: String,
        firstName: String,
        patronymicName: String,
        phoneNumber: String,
        balance: Double = 0,
        passport: PassportData = PassportData(),
        placeOfResidence: PlaceOfResidence = PlaceOfResidence(),
        treatmentPlan: TreatmentPlan? = nil,
        image: Data? = nil,
        transactions: [Payment]? = []
    ) {
        self.id = id
        self.secondName = secondName
        self.firstName = firstName
        self.patronymicName = patronymicName
        self.phoneNumber = phoneNumber
        self.balance = balance
        self.passport = passport
        self.placeOfResidence = placeOfResidence
        self.treatmentPlan = treatmentPlan
        self.createdAt = .now
        self.image = image
        self.transactions = transactions
    }

    func updateBalance(increment: Double) {
        balance += increment
    }

    func getTransactions() -> [any MoneyTransaction] {
        []
    }

    func mergedAppointments(forCheckID checkID: PersistentIdentifier) -> [PatientAppointment] {
        appointments?.filter { $0.check?.id == checkID } ?? []
    }

    func checks(for date: Date) -> [Check] {
        let checks = appointments?
            .filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: date) }
            .filter { $0.status != .completed }
            .compactMap { check(forAppointmentID: $0.id) } ?? []

        return Array(checks.uniqued())
    }

    func check(forAppointmentID appointmentID: UUID) -> Check? {
        guard let appointment = appointments?.first(where: { $0.id == appointmentID }) else { return nil }

        return appointment.check
    }

    func isNewPatient(for period: StatisticsPeriod) -> Bool {
        guard let firstVisit = appointments?.sorted(by: { $0.scheduledTime < $1.scheduledTime }).first else { return false }
        return firstVisit.scheduledTime > period.start()
    }

    func updateCheck(_ check: Check, forAppointmentID appointmentID: UUID) {
        guard let appointment = appointments?.first(where: { $0.id == appointmentID }) else { return }
        appointment.check = check
    }

    // MARK: - Codable

//    private enum CodingKeys: String, CodingKey {
//        case id, secondName, firstName, patronymicName, phoneNumber, balance, passport, placeOfResidence, treatmentPlan, createdAt, transactions
//    }
//
//    required init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(UUID.self, forKey: .id)
//        self.secondName = try container.decode(String.self, forKey: .secondName)
//        self.firstName = try container.decode(String.self, forKey: .firstName)
//        self.patronymicName = try container.decode(String.self, forKey: .patronymicName)
//        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
//        self.balance = try container.decode(Double.self, forKey: .balance)
//        self.passport = try container.decode(PassportData.self, forKey: .passport)
//        self.placeOfResidence = try container.decode(PlaceOfResidence.self, forKey: .placeOfResidence)
//        self.treatmentPlan = try container.decodeIfPresent(TreatmentPlan.self, forKey: .treatmentPlan)
//        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
//        self.transactions = try container.decodeIfPresent([Payment].self, forKey: .transactions)
//    }
//
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(secondName, forKey: .secondName)
//        try container.encode(firstName, forKey: .firstName)
//        try container.encode(patronymicName, forKey: .patronymicName)
//        try container.encode(phoneNumber, forKey: .phoneNumber)
//        try container.encode(balance, forKey: .balance)
//        try container.encode(passport, forKey: .passport)
//        try container.encode(placeOfResidence, forKey: .placeOfResidence)
//        try container.encode(treatmentPlan, forKey: .treatmentPlan)
//        try container.encode(createdAt, forKey: .createdAt)
//        try container.encode(transactions, forKey: .transactions)
//    }
}
