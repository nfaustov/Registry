//
//  Ledger+Schedules.swift
//  Registry
//
//  Created by Николай Фаустов on 07.06.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func topDoctorsByPatients(for date: Date, period: StatisticsPeriod, maxCount: Int) -> [DoctorsPopularity] {
        guard maxCount > 0 else { return [] }

        var doctorsPopularity: [DoctorsPopularity] = []

        let schedules = getSchedules(for: date, period: period)
        let groupedSchedules = Dictionary(grouping: schedules, by: { $0.doctor! })

        for (doctor, schedules) in groupedSchedules {
            let completedAppointments = schedules.flatMap { $0.completedAppointments }
            doctorsPopularity.append(DoctorsPopularity(doctor: doctor, patientsCount: completedAppointments.count))
        }

        let sortedPopularity = doctorsPopularity
            .sorted(by: { $0.patientsCount > $1.patientsCount })
            .prefix(maxCount)

        return Array(sortedPopularity)
    }

    func registrarActivity(for date: Date, period: StatisticsPeriod) -> [RegistrarActivity] {
        var registrarsActivity: [RegistrarActivity] = []

        let schedules = getSchedules(for: date, period: period)
        let completedAppointments = schedules.flatMap { $0.completedAppointments }
        let groupedAppointments = Dictionary(grouping: completedAppointments, by: { $0.registrar })

        for (registrar, appointments) in groupedAppointments {
            if let registrar, registrar.accessLevel < .boss {
                var activity = RegistrarActivity(registrar: registrar, activity: 0)

                for appointment in appointments {
                    if let patient = appointment.patient {
                        if patient.isNewPatient(for: date, period: period) {
                            activity.activity += 3
                        } else {
                            activity.activity += 2
                        }
                    }
                }

                registrarsActivity.append(activity)
            }
        }

        return registrarsActivity
    }

    func scheduledPatients(for date: Date, period: StatisticsPeriod) -> [Patient] {
        getSchedules(for: date, period: period).flatMap { $0.scheduledPatients }
    }

    func completedVisitPatients(for date: Date, period: StatisticsPeriod) -> [Patient] {
        getSchedules(for: date, period: period)
            .flatMap { $0.completedAppointments.compactMap { $0.patient } }
    }
}

// MARK: - Private methods

private extension Ledger {
    func getSchedules(for date: Date, period: StatisticsPeriod) -> [DoctorSchedule] {
        let start = period.start(for: date)
        let end = period.end(for: date)
        let predicate = #Predicate<DoctorSchedule> { $0.starting > start && $0.ending < end }
        let descriptor = FetchDescriptor<DoctorSchedule>(predicate: predicate)

        if let schedules = try? modelContext.fetch(descriptor) {
            return schedules
        } else { return [] }
    }
}

struct DoctorsPopularity: Hashable {
    let doctor: Doctor
    let patientsCount: Int
}

struct RegistrarActivity: Hashable {
    let registrar: AnyUser
    var activity: Int
}
