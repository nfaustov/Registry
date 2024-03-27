//
//  Message.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

public enum Message {
    case appointmentReminder(PatientAppointment)
    case appointmentConfirmation(PatientAppointment)

    var text: String {
        switch self {
        case .appointmentReminder(let patientAppointment):
            guard let schedule = patientAppointment.schedule,
                  let doctor = schedule.doctor else { return "" }

            let dateTime = DateFormat.dateTime.string(from: patientAppointment.scheduledTime)

            return "Ожидаем Вас \(dateTime) на прием к врачу \(doctor.initials). Клиника АртМедикс +7(4742)25-04-04, WA/TG: +7(991)217-04-40"
        case .appointmentConfirmation(let patientAppointment):
            guard let schedule = patientAppointment.schedule,
                  let doctor = schedule.doctor else { return "" }

            let dateTime = DateFormat.dateTime.string(from: patientAppointment.scheduledTime)

            return "Вы записаны \(dateTime) на прием к врачу \(doctor.initials). Клиника АртМедикс +7(4742)25-04-04, WA/TG: +7(991)217-04-40"
        }
    }
}
