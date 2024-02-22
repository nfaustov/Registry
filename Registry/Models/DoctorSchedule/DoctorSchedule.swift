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
    public var doctor: Doctor = Doctor(
        secondName: "",
        firstName: "",
        patronymicName: "",
        phoneNumber: "",
        birthDate: .now,
        department: .gynecology,
        basicService: nil,
        serviceDuration: 0,
        defaultCabinet: 1,
        salary: .pieceRate(rate: 0.4)
    )
    public var cabinet: Int = 1
    public var starting: Date = Date.now
    public var ending: Date = Date.now.addingTimeInterval(1800)
    public var patientAppointments: [PatientAppointment] = []

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
        self.patientAppointments = patientAppointments

        if self.patientAppointments.isEmpty {
            createAppointments()
        }
    }

    public var scheduledPatients: Int {
        patientAppointments
            .compactMap { $0.patient }
            .count
    }

    public var availableAppointments: Int {
        patientAppointments.count - scheduledPatients
    }

    public var duration: TimeInterval {
        ending.timeIntervalSince(starting)
    }

    /// Calculate available duration for patient's appointment.
    /// - Parameter appointment: Appointment for calculation.
    public func maxServiceDuration(for appointment: PatientAppointment) -> TimeInterval {
        if let nextReservedAppointment = patientAppointments
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
    public func splitToBasicDurationAppointments(_ appointment: PatientAppointment) -> [PatientAppointment] {
        if appointment.duration > doctor.serviceDuration {
            return createAppointments(
                on: DateInterval(start: appointment.scheduledTime, duration: appointment.duration)
            )
        } else {
            return [
                PatientAppointment(
                        scheduledTime: appointment.scheduledTime,
                        duration: appointment.duration,
                        patient: appointment.patient, 
                        status: .none
                )
            ]
        }
    }
}

// MARK: - Private methods

private extension DoctorSchedule {
    func createAppointments() {
        var appointmentTime = starting

        repeat {
            let appointment = PatientAppointment(
                scheduledTime: appointmentTime,
                duration: doctor.serviceDuration,
                patient: nil
            )
            patientAppointments.append(appointment)
            appointmentTime.addTimeInterval(doctor.serviceDuration)
        } while appointmentTime < ending
    }

    func createAppointments(on interval: DateInterval) -> [PatientAppointment] {
        var appointmentTime = interval.start
        var appointments = [PatientAppointment]()

        repeat {
            let appointment = PatientAppointment(
                scheduledTime: appointmentTime,
                duration: doctor.serviceDuration,
                patient: nil)
            appointments.append(appointment)
            appointmentTime.addTimeInterval(doctor.serviceDuration)
        } while appointmentTime < interval.end

        return appointments
    }
}

