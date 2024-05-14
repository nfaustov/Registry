//
//  Note.swift
//  Registry
//
//  Created by Николай Фаустов on 17.04.2024.
//

import Foundation
import SwiftData

@Model
final class Note {
    let title: String = ""
    private(set) var text: String = ""
    let createdAt: Date = Date.now
    let createdBy: AnyUser = AnonymousUser().asAnyUser

    var doctorSchedule: DoctorSchedule?
    var patientAppointment: PatientAppointment?

    static let charactersMax = 120

    init(text: String, createdBy: User) {
        if let doctorSchedule {
            let doctorInitials = doctorSchedule.doctor?.initials ?? ""
            let scheduleStarting = DateFormat.dateTime.string(from: doctorSchedule.starting)
            title = "Врач: \(doctorInitials) \(scheduleStarting)"
        } else if let patientAppointment {
            let patientInitials = patientAppointment.patient?.initials ?? ""
            let scheduledTime = DateFormat.dateTime.string(from: patientAppointment.scheduledTime)
            title = "Прием пациента: \(patientInitials) \(scheduledTime)"
        }

        self.text = text
        createdAt = .now
        self.createdBy = createdBy.asAnyUser
    }

    func updateText(_ text: String) {
        self.text = text
    }
}
