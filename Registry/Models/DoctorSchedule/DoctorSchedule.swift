//
//  DoctorSchedule.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation
import SwiftData

@Model
public final class DoctorSchedule {
    public var id: UUID = UUID()
    @Relationship(inverse: \Doctor.schedules)
    public var doctor: Doctor?
    public var cabinet: Int = 1
    public var starting: Date = Date.now
    public var ending: Date = Date.now.addingTimeInterval(1800)
    @Relationship(deleteRule: .cascade, inverse: \PatientAppointment.schedule)
    public var patientAppointments: [PatientAppointment]?

    public init(
        id: UUID = UUID(),
        doctor: Doctor,
        starting: Date,
        ending: Date,
        cabinet: Int,
        patientAppointments: [PatientAppointment] = []
    ) {
        self.id = id
        self.doctor = doctor
        self.cabinet = cabinet
        self.starting = starting
        self.ending = ending

        if patientAppointments.isEmpty {
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

    public var scheduledPatients: [Patient] {
        guard let patientAppointments else { return [] }

        return patientAppointments
            .filter { $0.status != .cancelled }
            .compactMap { $0.patient }
    }

    public var cancelledPatients: [Patient] {
        guard let patientAppointments else { return [] }

        return patientAppointments
            .filter { $0.status == .cancelled }
            .compactMap { $0.patient }
    }

    public var availableAppointments: Int {
        guard let patientAppointments else { return 0 }
        return patientAppointments.filter({ $0.status != .cancelled }).count - scheduledPatients.count
    }

    public var duration: TimeInterval {
        ending.timeIntervalSince(starting)
    }

    /// Calculate available duration for patient's appointment.
    /// - Parameter appointment: Appointment for calculation.
    public func maxServiceDuration(for appointment: PatientAppointment) -> TimeInterval {
        if let nextReservedAppointment = patientAppointments?
            .filter({ $0.scheduledTime > appointment.scheduledTime })
            .first(where: { $0.patient != nil }) {
            return nextReservedAppointment.scheduledTime.timeIntervalSince(appointment.scheduledTime)
        } else {
            return ending.timeIntervalSince(appointment.scheduledTime)
        }
    }

    /// Split appointment to several appointments with doctor service duration.
    /// - Parameter appointment: Appointment for splitting.
    /// - Returns: Array of empty appointments which have been created on time interval of duration of given appointment.
    public func splitToBasicDurationAppointments(_ appointment: PatientAppointment) {
        if appointment.duration > doctor?.serviceDuration ?? 0 {
            createAppointments(
                on: DateInterval(start: appointment.scheduledTime, duration: appointment.duration)
            )
        } else {
            let newAppointment = PatientAppointment(
                scheduledTime: appointment.scheduledTime,
                duration: appointment.duration,
                patient: nil
            )
            patientAppointments?.append(newAppointment)
        }
    }
}

// MARK: - Private methods

private extension DoctorSchedule {
    func createAppointments(on interval: DateInterval) {
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

