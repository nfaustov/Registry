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

    init(title: String, text: String, createdBy: User) {
        self.title = title
        self.text = text
        createdAt = .now
        self.createdBy = createdBy.asAnyUser
    }

    func updateText(_ text: String) {
        self.text = text
    }
}
