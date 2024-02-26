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
    public var id: UUID = UUID()
    public var scheduledTime: Date = Date.now
    public var duration: TimeInterval = TimeInterval.zero
    public var patient: Patient?
    public var status: PatientAppointment.Status = PatientAppointment.Status.none

    public var schedule: DoctorSchedule?

    public var endTime: Date {
        scheduledTime.addingTimeInterval(duration)
    }

    public init(
        id: UUID = UUID(),
        scheduledTime: Date,
        duration: TimeInterval,
        patient: Patient?,
        status: Status = .none
    ) {
        self.id = id
        self.scheduledTime = scheduledTime
        self.duration = duration
        self.patient = patient
        self.status = status
    }
}

extension PatientAppointment {
    public enum Status: String, Codable, CaseIterable, Identifiable {
        case none
        case registered = "Зарегистрирован"
        case confirmed = "Подтвержден"
        case came = "Пришел"
        case inProgress = "На приеме"
        case completed = "Завершен"
        case cancelled = "Отменен"

        public var id: Self {
            self
        }

        public static var allCases: [Status] {
            [.registered, .confirmed, .came, .inProgress]
        }
    }
}
