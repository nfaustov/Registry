//
//  Patient.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
final class Patient: AccountablePerson, Codable {
    let id: UUID = UUID()
    var secondName: String = ""
    var firstName: String =  ""
    var patronymicName: String = ""
    var phoneNumber: String = ""
    private(set) var balance: Double = Double.zero
    var passport: PassportData = PassportData()
    var placeOfResidence: PlaceOfResidence = PlaceOfResidence()
    @Relationship(deleteRule: .cascade, inverse: \TreatmentPlan.patient)
    private(set) var treatmentPlans: [TreatmentPlan]?
    let createdAt: Date = Date.now
    @Attribute(.externalStorage)
    var image: Data?
    @Relationship(inverse: \Payment.patient)
    private(set) var transactions: [Payment]? = []

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
        treatmentPlans: [TreatmentPlan]? = [],
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
        self.treatmentPlans = treatmentPlans
        self.createdAt = .now
        self.image = image
        self.transactions = transactions
    }

    var currentTreatmentPlan: TreatmentPlan? {
        treatmentPlans?.first(where: { $0.expirationDate > .now })
    }

    var treatmentPlanChecks: [Check] {
        guard let currentTreatmentPlan else { return [] }

        return transactions?
            .filter {
                $0.date > currentTreatmentPlan.startingDate && $0.date < currentTreatmentPlan.expirationDate
            }
            .compactMap { $0.subject }
            .filter { $0.refund == nil } ?? []
    }

    func activateTreatmentPlan(ofKind kind: TreatmentPlan.Kind) {
        guard currentTreatmentPlan == nil else { return }

        let newTreatmentPlan = TreatmentPlan(kind: kind)
        treatmentPlans?.append(newTreatmentPlan)
    }

    func deactivateTreatmentPlan() {
        guard let currentTreatmentPlan else { return }
        treatmentPlans?.removeAll(where: { $0.id == currentTreatmentPlan.id })
    }

    func updateBalance(increment: Double) {
        balance += increment
    }

    func assignTransaction(_ transaction: Payment) {
        transactions?.append(transaction)
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
            .compactMap { $0.check } ?? []

        return Array(checks.uniqued())
    }

    func isNewPatient(for period: StatisticsPeriod) -> Bool {
        guard let firstVisit = appointments?.sorted(by: { $0.scheduledTime < $1.scheduledTime }).first else { return false }
        return firstVisit.scheduledTime > period.start()
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id, secondName, firstName, patronymicName, phoneNumber, balance, passport, placeOfResidence, treatmentPlans, createdAt, transactions
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.secondName = try container.decode(String.self, forKey: .secondName)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.patronymicName = try container.decode(String.self, forKey: .patronymicName)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.balance = try container.decode(Double.self, forKey: .balance)
        self.passport = try container.decode(PassportData.self, forKey: .passport)
        self.placeOfResidence = try container.decode(PlaceOfResidence.self, forKey: .placeOfResidence)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(secondName, forKey: .secondName)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(patronymicName, forKey: .patronymicName)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(balance, forKey: .balance)
        try container.encode(passport, forKey: .passport)
        try container.encode(placeOfResidence, forKey: .placeOfResidence)
        try container.encode(createdAt, forKey: .createdAt)
    }
}
