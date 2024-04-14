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
    public var balance: Double = Double.zero
    public var passport: PassportData = PassportData()
    public var placeOfResidence: PlaceOfResidence = PlaceOfResidence()
    public var treatmentPlan: TreatmentPlan?
    public let createdAt: Date = Date.now
    public var visits: [Visit] = []
    public var image: Data?
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
        visits: [Visit] = [],
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
        self.visits = visits
        self.image = image
    }

    public func mergedAppointments(forAppointmentID appointmentID: UUID) -> [PatientAppointment] {
        if let visit = visit(forAppointmentID: appointmentID) {
            appointments?.filter { $0.visitID == visit.id } ?? []
        } else {
            []
        }
    }

    public func mergedAppointments(forVisitID visitID: Visit.ID) -> [PatientAppointment] {
        appointments?.filter { $0.visitID == visitID } ?? []
    }

    public func currentVisits(for date: Date) -> [Visit] {
        let visits = appointments?
            .filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: date) }
            .filter { $0.status != .completed }
            .compactMap { visit(forAppointmentID: $0.id) } ?? []

        return Array(visits.uniqued())
    }

    public func visit(forAppointmentID appointmentID: UUID) -> Visit? {
        guard let appointment = appointments?.first(where: { $0.id == appointmentID }) else { return nil }

        return visits.first(where: { $0.id == appointment.visitID })
    }

    public func isNewPatient(for period: StatisticsPeriod) -> Bool {
        guard let firstVisit = visits.sorted(by: { $0.visitDate < $1.visitDate }).first, firstVisit.cancellationDate == nil else { return false }
        return firstVisit.visitDate > period.start()
    }

    public func updateBalance(increment: Double) {
        balance += increment
    }

    public func cancelVisit(for appointmentID: UUID) {
        guard let visit = visit(forAppointmentID: appointmentID), let visitIndex = visits.firstIndex(of: visit) else { return }

        var updatedVisit = visits.remove(at: visitIndex)
        updatedVisit.cancellationDate = .now
        updatedVisit.bill = nil

        visits.append(updatedVisit)
    }

    public func updatePaymentSubject(_ subject: Payment.Subject, forAppointmentID appointmentID: UUID) {
        guard let visit = visit(forAppointmentID: appointmentID),
              let visitIndex = visits.firstIndex(of: visit) else { return }

        var updatedVisit = visits.remove(at: visitIndex)

        switch subject {
        case .bill(let bill): updatedVisit.bill = bill
        case .refund(let refund): updatedVisit.refund = refund
        }

        visits.append(updatedVisit)
    }

    public func specifyVisitDate(_ visitID: Visit.ID) {
        guard let visitIndex = visits.firstIndex(where: { $0.id == visitID }) else { return }

        var updatedVisit = visits.remove(at: visitIndex)

        if let firstVisitAppointment = mergedAppointments(forVisitID: updatedVisit.id)
            .sorted(by: { $0.scheduledTime < $1.scheduledTime })
            .first {
            updatedVisit.visitDate = firstVisitAppointment.scheduledTime
            visits.append(updatedVisit)
        }
    }
}
