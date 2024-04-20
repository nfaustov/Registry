//
//  Note.swift
//  Registry
//
//  Created by Николай Фаустов on 17.04.2024.
//

import Foundation
import SwiftData

extension RegistrySchemaV2 {
    @Model
    final class Note {
        var title: String = ""
        var text: String = ""
        let createdAt: Date = Date.now
        let createdBy: AnyUser = AnonymousUser().asAnyUser

        var doctorSchedule: DoctorSchedule?
        var patientAppointment: PatientAppointment?

        init(text: String, createdBy: AnyUser) {
            self.text = text
            self.createdAt = .now
            self.createdBy = createdBy
        }
    }
}

extension RegistrySchemaV3 {
    @Model
    final class Note {
        var title: String = ""
        var text: String = ""
        let createdAt: Date = Date.now
        let createdBy: AnyUser = AnonymousUser().asAnyUser

        var doctorSchedule: DoctorSchedule?
        var patientAppointment: PatientAppointment?

        init(text: String, createdBy: AnyUser) {
            self.text = text
            self.createdAt = .now
            self.createdBy = createdBy
        }
    }
}
