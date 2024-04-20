//
//  DoctorSchedule.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
final class DoctorSchedule {
    let id: UUID = UUID()
    @Relationship(inverse: \Doctor.schedules)
    var doctor: Doctor?
    var cabinet: Int = 1
    var starting: Date = Date.now
    var ending: Date = Date.now.addingTimeInterval(1800)
    @Relationship(deleteRule: .cascade, inverse: \Note.doctorSchedule)
    var note: Note? = nil
    @Relationship(deleteRule: .cascade, inverse: \PatientAppointment.schedule)
    var patientAppointments: [PatientAppointment]?

    init(
        id: UUID = UUID(),
        doctor: Doctor,
        cabinet: Int,
        starting: Date,
        ending: Date,
        note: Note? = nil,
        patientAppointments: [PatientAppointment] = []
    ) {
        self.id = id
        self.doctor = doctor
        self.cabinet = cabinet
        self.starting = starting
        self.ending = ending

        if doctor.department != .procedure, patientAppointments.isEmpty {
            var appointmentTime = starting
            var appointments = [PatientAppointment]()

            repeat {
                let appointment = PatientAppointment(
                    scheduledTime: appointmentTime,
                    duration: doctor.serviceDuration,
                    patient: nil
                )
                appointments.append(appointment)
                appointmentTime.addTimeInterval(doctor.serviceDuration)
            } while appointmentTime < ending

            self.patientAppointments = appointments
        } else {
            self.patientAppointments = patientAppointments
        }
    }

    var scheduledPatients: [Patient] {
        guard let patientAppointments else { return [] }

        return patientAppointments
            .compactMap { $0.patient }
    }

    var availableAppointments: Int {
        guard let patientAppointments else { return 0 }

        return patientAppointments.count - scheduledPatients.count
    }

    var completedAppointments: [PatientAppointment] {
        patientAppointments?.filter { $0.status == .completed } ?? []
    }

    var duration: TimeInterval {
        ending.timeIntervalSince(starting)
    }

    /// Calculate available duration for patient's appointment.
    /// - Parameter appointment: Appointment for calculation.
    func maxServiceDuration(forAppointmentTime time: Date) -> TimeInterval {
        if let nextReservedAppointment = patientAppointments?
            .filter({ $0.scheduledTime > time })
            .first(where: { $0.patient != nil }) {
            return nextReservedAppointment.scheduledTime.timeIntervalSince(time)
        } else {
            return ending.timeIntervalSince(time)
        }
    }

    func cancelPatientAppointment(_ appointment: PatientAppointment) {
        guard let doctor else { return }

        if appointment.duration > doctor.serviceDuration {
            patientAppointments?.removeAll(where: { $0.id == appointment.id })
            createAppointments(
                on: DateInterval(
                    start: appointment.scheduledTime,
                    duration: appointment.duration
                )
            )
        } else {
            appointment.cancel()
        }
    }

    func createPatientAppointment(date: Date, completion: @escaping (PatientAppointment) -> Void) {
        let appointment = PatientAppointment(
            scheduledTime: date,
            duration: doctor?.serviceDuration ?? Double.zero,
            patient: nil
        )
        patientAppointments?.append(appointment)
        completion(appointment)
    }

    private func createAppointments(on interval: DateInterval) {
        var appointmentTime = interval.start

        repeat {
            let appointment = PatientAppointment(
                scheduledTime: appointmentTime,
                duration: doctor?.serviceDuration ?? 0,
                patient: nil)
            patientAppointments?.append(appointment)
            appointmentTime.addTimeInterval(doctor?.serviceDuration ?? 0)
        } while appointmentTime < interval.end
    }
}
