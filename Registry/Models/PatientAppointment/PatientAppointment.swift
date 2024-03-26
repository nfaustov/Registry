//
//  PatientAppointment.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import Foundation
import SwiftData

@Model
public final class PatientAppointment {
    public let id: UUID = UUID()
    public let scheduledTime: Date = Date.now
    public private(set) var duration: TimeInterval = TimeInterval.zero
    @Relationship(inverse: \Patient.appointments)
    public private(set) var patient: Patient?
    public var status: PatientAppointment.Status?
    public private(set) var visitID: Visit.ID?
    public var schedule: DoctorSchedule?
    
    public var endTime: Date {
        scheduledTime.addingTimeInterval(duration)
    }
    
    public init(
        id: UUID = UUID(),
        scheduledTime: Date,
        duration: TimeInterval,
        patient: Patient?,
        status: PatientAppointment.Status? = nil,
        visitID: Visit.ID? = nil
    ) {
        self.id = id
        self.scheduledTime = scheduledTime
        self.duration = duration
        self.patient = patient
        self.status = status
        self.visitID = visitID
    }
    
    public func registerPatient(_ patient: Patient, duration: TimeInterval, registrar: AnyUser) {
        if let currentVisit = patient.currentVisit(for: scheduledTime) {
            visitID = currentVisit.id
        } else {
            let visit = Visit(registrar: registrar, visitDate: scheduledTime)
            patient.visits.append(visit)
            visitID = visit.id
        }

        self.patient = patient
        self.duration = duration
        status = .registered
    }

    public func cancel() {
        patient = nil
        status = nil
        visitID = nil
    }
}

extension PatientAppointment {
    public enum Status: String, Codable, CaseIterable, Identifiable {
        case registered = "Зарегистрирован"
        case confirmed = "Подтвержден"
        case came = "Пришел"
        case inProgress = "На приеме"
        case completed = "Завершен"

        public var id: Self {
            self
        }

        public static var allCases: [Status] {
            [.registered, .confirmed, .came, .inProgress]
        }
    }
}
