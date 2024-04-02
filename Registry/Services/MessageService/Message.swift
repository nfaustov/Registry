//
//  Message.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

public enum Message {
    case appointmentConfirmation(PatientAppointment)

    var text: String {
        switch self {
        case .appointmentConfirmation(let patientAppointment):
            guard let schedule = patientAppointment.schedule,
                  let doctor = schedule.doctor else { return "" }

            let date = DateFormat.date.string(from: patientAppointment.scheduledTime)
            let time = DateFormat.time.string(from: patientAppointment.scheduledTime)

            return "Ожидаем Вас \(date) в \(time) на прием к врачу \(doctor.initials) Клиника АртМедикс wa.me/79912170440 8(4742)25-04-04"
        }
    }

    var sendingTime: Date? {
        switch self {
        case .appointmentConfirmation:
            .now.addingTimeInterval(60)
        }
    }

    var phoneNumber: String? {
        switch self {
        case .appointmentConfirmation(let patientAppointment):
            patientAppointment.patient?.phoneNumber
        }
    }
}
