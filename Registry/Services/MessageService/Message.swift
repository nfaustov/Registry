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

            let dateTime = DateFormat.dateTime.string(from: patientAppointment.scheduledTime)

            return "Вы записаны \(dateTime) на прием к врачу \(doctor.initials) Клиника АртМедикс 8(4742)25-04-04 wa.me/79912170440"
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
