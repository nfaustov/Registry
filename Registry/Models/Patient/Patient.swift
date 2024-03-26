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
    public var id: UUID = UUID()
    public var secondName: String = ""
    public var firstName: String =  ""
    public var patronymicName: String = ""
    public var phoneNumber: String = ""
    public private(set) var balance: Double = Double.zero
    public var passport: PassportData = PassportData()
    public var placeOfResidence: PlaceOfResidence = PlaceOfResidence()
    public var treatmentPlan: TreatmentPlan?
    public var createdAt: Date = Date.now
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

    public func appointments(for date: Date) -> [PatientAppointment] {
        appointments?.filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: date) } ?? []
    }

    public func visit(for date: Date) -> Visit? {
        visits.first(where: { Calendar.current.isDate($0.visitDate, inSameDayAs: date) })
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
        guard var visit = visit(for: date) else { return }

        visit.cancellationDate = .now
        visit.bill = nil
    }

    public func updatePaymentSubject(_ subject: Payment.Subject, for appointment: PatientAppointment) {
        guard var visit = visit(for: appointment.scheduledTime) else { return }

        switch subject {
        case .bill(let bill): visit.bill = bill
        case .refund(let refund): visit.refund = refund
        }
    }
}
