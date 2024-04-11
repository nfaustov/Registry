//
//  Message.swift
//  Registry
//
//  Created by Николай Фаустов on 13.03.2024.
//

import Foundation

public enum Message {
    case appointmentConfirmation(PatientAppointment)
    case appointmentReminder(PatientAppointment)

    var text: String? {
        switch self {
        case .appointmentConfirmation(let patientAppointment):
            text(for: patientAppointment)
        case .appointmentReminder(let patientAppointment):
            text(for: patientAppointment)
        }
    }

    var sendingTime: Date? {
        switch self {
        case .appointmentConfirmation:
            .now.addingTimeInterval(60)
        default: nil
        }
    }

    var phoneNumber: String? {
        switch self {
        case .appointmentConfirmation(let patientAppointment):
            patientAppointment.patient?.phoneNumber
        case .appointmentReminder(let patientAppointment):
            patientAppointment.patient?.phoneNumber
        }
    }
}

private extension Message {
    func text(for appointment: PatientAppointment) -> String? {
        guard let schedule = appointment.schedule,
              let doctor = schedule.doctor else { return nil }

        let date = DateFormat.date.string(from: appointment.scheduledTime)
        let time = DateFormat.time.string(from: appointment.scheduledTime)

        switch self {
        case .appointmentConfirmation:
            return "Вы записаны \(date) в \(time) на прием к врачу \(doctor.initials) Клиника АртМедикс artmedics.ru wa.me/79912170440"
        case .appointmentReminder:
            return "Ожидаем Вас \(date) в \(time) на прием к врачу \(doctor.initials) Клиника АртМедикс artmedics.ru wa.me/79912170440"
        }
    }
}
