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
    var balance: Double = Double.zero
    var passport: PassportData = PassportData()
    var placeOfResidence: PlaceOfResidence = PlaceOfResidence()
    var treatmentPlan: TreatmentPlan?
    let createdAt: Date = Date.now
    @Attribute(.externalStorage)
    var image: Data?

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
        image: Data? = nil
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
}
