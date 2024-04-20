//
//  Patient.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

extension RegistrySchemaV1 {
    @Model
    final class Patient: Person {
        let id: UUID = UUID()
        var secondName: String = ""
        var firstName: String =  ""
        var patronymicName: String = ""
        var phoneNumber: String = ""
        var balance: Double = Double.zero
        var passport: RegistrySchemaV3.Patient.PassportData = RegistrySchemaV3.Patient.PassportData()
        var placeOfResidence: RegistrySchemaV3.Patient.PlaceOfResidence = RegistrySchemaV3.Patient.PlaceOfResidence()
        var treatmentPlan: TreatmentPlan?
        let createdAt: Date = Date.now
        var visits: [Visit] = []
        var image: Data?
        var appointments: [PatientAppointment]?

        init(
            id: UUID = UUID(),
            secondName: String,
            firstName: String,
            patronymicName: String,
            phoneNumber: String,
            balance: Double = 0,
            passport: RegistrySchemaV3.Patient.PassportData = RegistrySchemaV3.Patient.PassportData(),
            placeOfResidence: RegistrySchemaV3.Patient.PlaceOfResidence = RegistrySchemaV3.Patient.PlaceOfResidence(),
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

        func mergedAppointments(forAppointmentID appointmentID: UUID) -> [PatientAppointment] {
            if let visit = visit(forAppointmentID: appointmentID) {
                appointments?.filter { $0.visitID == visit.id } ?? []
            } else {
                []
            }
        }

        func mergedAppointments(forVisitID visitID: Visit.ID) -> [PatientAppointment] {
            appointments?.filter { $0.visitID == visitID } ?? []
        }

        func currentVisits(for date: Date) -> [Visit] {
            let visits = appointments?
                .filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: date) }
                .filter { $0.status != .completed }
                .compactMap { visit(forAppointmentID: $0.id) } ?? []

            return Array(visits.uniqued())
        }

        func visit(forAppointmentID appointmentID: UUID) -> Visit? {
            guard let appointment = appointments?.first(where: { $0.id == appointmentID }) else { return nil }

            return visits.first(where: { $0.id == appointment.visitID })
        }

        func isNewPatient(for period: StatisticsPeriod) -> Bool {
            guard let firstVisit = visits.sorted(by: { $0.visitDate < $1.visitDate }).first, firstVisit.cancellationDate == nil else { return false }
            return firstVisit.visitDate > period.start()
        }

        func updateBalance(increment: Double) {
            balance += increment
        }

        func cancelVisit(for appointmentID: UUID) {
            guard let visit = visit(forAppointmentID: appointmentID), let visitIndex = visits.firstIndex(of: visit) else { return }

            var updatedVisit = visits.remove(at: visitIndex)
            updatedVisit.cancellationDate = .now
            updatedVisit.bill = nil

            visits.append(updatedVisit)
        }

        func updatePaymentSubject(_ subject: Payment.Subject, forAppointmentID appointmentID: UUID) {
            guard let visit = visit(forAppointmentID: appointmentID),
                  let visitIndex = visits.firstIndex(of: visit) else { return }

            var updatedVisit = visits.remove(at: visitIndex)

            switch subject {
            case .bill(let bill): updatedVisit.bill = bill
            case .refund(let refund): updatedVisit.refund = refund
            }

            visits.append(updatedVisit)
        }

        func specifyVisitDate(_ visitID: Visit.ID) {
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
}

extension RegistrySchemaV2 {
    @Model
    final class Patient: Person {
        let id: UUID = UUID()
        var secondName: String = ""
        var firstName: String =  ""
        var patronymicName: String = ""
        var phoneNumber: String = ""
        var balance: Double = Double.zero
        var passport: RegistrySchemaV3.Patient.PassportData = RegistrySchemaV3.Patient.PassportData()
        var placeOfResidence: RegistrySchemaV3.Patient.PlaceOfResidence = RegistrySchemaV3.Patient.PlaceOfResidence()
        var treatmentPlan: TreatmentPlan?
        let createdAt: Date = Date.now
        var visits: [Visit] = []
        var image: Data?
        var appointments: [PatientAppointment]?

        init(
            id: UUID = UUID(),
            secondName: String,
            firstName: String,
            patronymicName: String,
            phoneNumber: String,
            balance: Double = 0,
            passport: RegistrySchemaV3.Patient.PassportData = RegistrySchemaV3.Patient.PassportData(),
            placeOfResidence: RegistrySchemaV3.Patient.PlaceOfResidence = RegistrySchemaV3.Patient.PlaceOfResidence(),
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

        func mergedAppointments(forAppointmentID appointmentID: UUID) -> [PatientAppointment] {
            if let visit = visit(forAppointmentID: appointmentID) {
                appointments?.filter { $0.visitID == visit.id } ?? []
            } else {
                []
            }
        }

        func mergedAppointments(forVisitID visitID: Visit.ID) -> [PatientAppointment] {
            appointments?.filter { $0.visitID == visitID } ?? []
        }

        func currentVisits(for date: Date) -> [Visit] {
            let visits = appointments?
                .filter { Calendar.current.isDate($0.scheduledTime, inSameDayAs: date) }
                .filter { $0.status != .completed }
                .compactMap { visit(forAppointmentID: $0.id) } ?? []

            return Array(visits.uniqued())
        }

        func visit(forAppointmentID appointmentID: UUID) -> Visit? {
            guard let appointment = appointments?.first(where: { $0.id == appointmentID }) else { return nil }

            return visits.first(where: { $0.id == appointment.visitID })
        }

        func isNewPatient(for period: StatisticsPeriod) -> Bool {
            guard let firstVisit = visits.sorted(by: { $0.visitDate < $1.visitDate }).first, firstVisit.cancellationDate == nil else { return false }
            return firstVisit.visitDate > period.start()
        }

        func updateBalance(increment: Double) {
            balance += increment
        }

        func cancelVisit(for appointmentID: UUID) {
            guard let visit = visit(forAppointmentID: appointmentID), let visitIndex = visits.firstIndex(of: visit) else { return }

            var updatedVisit = visits.remove(at: visitIndex)
            updatedVisit.cancellationDate = .now
            updatedVisit.bill = nil

            visits.append(updatedVisit)
        }

        func specifyVisitDate(_ visitID: Visit.ID) {
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
}

extension RegistrySchemaV3 {
    @Model
    final class Patient: Person {
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
}
