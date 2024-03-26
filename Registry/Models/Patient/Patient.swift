//
//  Patient.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
public final class Patient: Person {
    public let id: UUID = UUID()
    public var secondName: String = ""
    public var firstName: String =  ""
    public var patronymicName: String = ""
    public var phoneNumber: String = ""
    public private(set) var balance: Double = Double.zero
    public var passport: PassportData = PassportData()
    public var placeOfResidence: PlaceOfResidence = PlaceOfResidence()
    public var treatmentPlan: TreatmentPlan?
    public let createdAt: Date = Date.now
    public var visits: [Visit] = []
    public var appointments: [PatientAppointment]?

    public init(
        id: UUID = UUID(),
        secondName: String,
        firstName: String,
        patronymicName: String,
        phoneNumber: String,
        balance: Double = 0,
        passport: PassportData = PassportData(),
        placeOfResidence: PlaceOfResidence = PlaceOfResidence(),
        treatmentPlan: TreatmentPlan? = nil,
        visits: [Visit] = []
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
        self.visits = visits
    }

    public func incompleteAppointments(for date: Date) -> [PatientAppointment] {
        appointments?
            .filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: date) }
            .filter { $0.status != .completed } ?? []
    }

    public func unpaidVisit(for date: Date) -> Visit? {
        var unpaidVisit: Visit? = nil

        for appointment in incompleteAppointments(for: date) {
            if let visit = visits.first(where: { $0.visitDate == appointment.scheduledTime }) {
                unpaidVisit = visit
            }
        }

        return unpaidVisit
    }

    public func isNewPatient(for period: StatisticsPeriod) -> Bool {
        visits
            .filter { $0.visitDate < period.start }
            .isEmpty
    }

    public func updateBalance(increment: Double) {
        balance += increment
    }

    public func cancelVisit(for date: Date) {
        guard var visit = unpaidVisit(for: date) else { return }

        visit.cancellationDate = .now
        visit.bill = nil
    }

    public func updatePaymentSubject(_ subject: Payment.Subject, for appointment: PatientAppointment) {
        guard var visit = unpaidVisit(for: appointment.scheduledTime) else { return }

        switch subject {
        case .bill(let bill): visit.bill = bill
        case .refund(let refund): visit.refund = refund
        }
    }
}
