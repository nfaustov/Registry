//
//  Message.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

public enum Message {
    case authorizationCode(String)
    case appointmentReminder(PatientAppointment)
    case appointmentConfirmation(PatientAppointment)

    var text: String {
        switch self {
        case .authorizationCode(let string):
            return string
        case .appointmentReminder(let patientAppointment):
            guard let schedule = patientAppointment.schedule,
                  let doctor = schedule.doctor else { return "" }

            let time = DateFormat.time.string(from: patientAppointment.scheduledTime)

            return "Ожидаем Вас завтра в \(time). Запись к врачу \(doctor.initials). Клиника АртМедикс +7 (4742) 25-04-04"
        case .appointmentConfirmation(let patientAppointment):
            guard let schedule = patientAppointment.schedule,
                  let doctor = schedule.doctor else { return "" }

            let dateTime = DateFormat.dateTime.string(from: patientAppointment.scheduledTime)

            return "Вы записаны на \(dateTime), врач \(doctor.initials). Клиника АртМедикс"
        }
    }
}
