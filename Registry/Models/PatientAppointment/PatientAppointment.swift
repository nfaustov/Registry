//
//  PatientAppointment.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import Foundation
import SwiftData

@Model
final class PatientAppointment {
    let id: UUID = UUID()
    let scheduledTime: Date = Date.now
    private(set) var duration: TimeInterval = TimeInterval.zero
    @Relationship(inverse: \Patient.appointments)
    private(set) var patient: Patient?
    var status: PatientAppointment.Status?
    @Relationship(deleteRule: .cascade, inverse: \Note.patientAppointment)
    var note: Note? = nil
    private(set) var registrationDate: Date? = nil
    private(set) var registrar: AnyUser? = nil
    @Relationship(inverse: \Check.appointments)
    var check: Check? = nil

    var schedule: DoctorSchedule?

    var endTime: Date {
        scheduledTime.addingTimeInterval(duration)
    }

    init(
        id: UUID = UUID(),
        scheduledTime: Date,
        duration: TimeInterval,
        patient: Patient? = nil,
        status: PatientAppointment.Status? = nil,
        note: Note? = nil,
        registrationDate: Date? = nil,
        registrar: AnyUser? = nil,
        check: Check? = nil
    ) {
        self.id = id
        self.scheduledTime = scheduledTime
        self.duration = duration
        self.patient = patient
        self.status = status
        self.note = note
        self.registrationDate = registrationDate
        self.registrar = registrar
        self.check = check
    }

    func registerPatient(
        _ patient: Patient,
        duration: TimeInterval,
        registrar: AnyUser,
        mergedCheck: Check? = nil
    ) {
        self.registrar = registrar
        registrationDate = .now
        self.patient = patient
        self.duration = duration
        status = .registered

        if let check = mergedCheck {
            self.check = check
        } else {
            if let doctor = schedule?.doctor, let pricelistItem = doctor.defaultPricelistItem {
                let service = MedicalService(
                    pricelistItem: pricelistItem.snapshot,
                    performer: pricelistItem.category == .laboratory ? nil : doctor
                )
                check = Check(services: [service])
            } else {
                check = Check()
            }
        }
    }

    func cancel() {
        patient = nil
        status = nil
        note = nil
        registrationDate = nil
        registrar = nil
        check = nil
    }
}

extension PatientAppointment {
    enum Status: String, Codable, Identifiable {
        case registered = "Зарегистрирован"
        case notified = "СМС уведомление"
        case came = "Пришел"
        case inProgress = "На приеме"
        case completed = "Завершен"

        var id: Self {
            self
        }

        static var selectableCases: [Status] {
            [.registered, .came, .inProgress]
        }
    }
}

