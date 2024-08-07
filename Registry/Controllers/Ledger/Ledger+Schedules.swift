//
//  Ledger+Schedules.swift
//  Registry
//
//  Created by Николай Фаустов on 07.06.2024.
//

import Foundation
import SwiftData

extension Ledger {
    func doctorsByPatients(for date: Date, period: StatisticsPeriod) -> [DoctorIndicator] {
        var doctorsPopularity: [DoctorIndicator] = []
        let schedules = getSchedules(for: date, period: period)
        let groupedSchedules = Dictionary(grouping: schedules, by: { $0.doctor! })

        for (doctor, schedules) in groupedSchedules {
            let completedAppointments = schedules.flatMap { $0.completedAppointments }
            doctorsPopularity.append(DoctorIndicator(doctor: doctor, indicator: completedAppointments.count))
        }

        let sortedPopularity = doctorsPopularity
            .sorted(by: { $0.indicator > $1.indicator })

        return sortedPopularity
    }

    func doctorsRevenue(for date: Date, period: StatisticsPeriod) -> [DoctorIndicator] {
        var doctorsRevenue: [DoctorIndicator] = []
        let doctors: [Doctor] = database.getModels()

        for doctor in doctors {
            if let services = doctor.performedServices {
                let filteredServices = services.filter { service in
                    if let serviceDate = service.date {
                        return serviceDate > period.start(for: date) && serviceDate < period.end(for: date)
                    } else { return false }
                }
                let revenue = filteredServices.reduce(0.0) { partialResult, service in
                    let discount = (service.check?.discountRate ?? 0) * service.price
                    return partialResult + service.price - discount
                }

                if revenue > 0 {
                    doctorsRevenue.append(DoctorIndicator(doctor: doctor, indicator: Int(revenue)))
                }
            }
        }

        return doctorsRevenue
            .sorted(by: { $0.indicator > $1.indicator })
    }

    func doctorsAgentFee(for date: Date, period: StatisticsPeriod) -> [DoctorIndicator] {
        var doctorsAgentFee: [DoctorIndicator] = []
        let doctors: [Doctor] = database.getModels()

        for doctor in doctors {
            if let services = doctor.appointedServices {
                let filteredServices = services.filter { service in
                    if let serviceDate = service.date {
                        return serviceDate > period.start(for: date) && serviceDate < period.end(for: date)
                    } else { return false }
                }
                let agentFee = filteredServices.reduce(0.0) { $0 + $1.agentFee }

                if agentFee > 0 {
                    doctorsAgentFee.append(DoctorIndicator(doctor: doctor, indicator: Int(agentFee)))
                }
            }
        }

        let sortedAgentFee = doctorsAgentFee
            .sorted(by: { $0.indicator > $1.indicator })

        return sortedAgentFee
    }

    func registrarActivity(for date: Date, period: StatisticsPeriod) -> [RegistrarActivity] {
        var registrarsActivity: [RegistrarActivity] = []
        let schedules = getSchedules(for: date, period: period)
        let completedAppointments = schedules.flatMap { $0.completedAppointments }
        let groupedAppointments = Dictionary(grouping: completedAppointments, by: { $0.registrar?.id })

        for (id, appointments) in groupedAppointments {
            if let id, let registrar = getDoctor(by: id), registrar.accessLevel < .boss {
                var activity = RegistrarActivity(registrar: registrar, activity: 0)
                let dailyAppointments = Dictionary(grouping: appointments, by: { Calendar.current.startOfDay(for: $0.scheduledTime) })

                for (day, appointments) in dailyAppointments {
                    let uniquedDailyPatients = appointments
                        .compactMap { $0.patient }
                        .uniqued()

                    for patient in uniquedDailyPatients {
                        if patient.isNewPatient(for: day, period: .day) {
                            activity.activity += 3
                        } else {
                            activity.activity += 2
                        }
                    }
                }

                registrarsActivity.append(activity)
            }
        }

        return registrarsActivity.sorted(by: { $0.activity > $1.activity})
    }

    func registrarAppointments(_ registrar: Doctor, for date: Date, period: StatisticsPeriod) -> [PatientAppointment] {
        let schedules = getSchedules(for: date, period: period)

        return schedules
            .flatMap { $0.completedAppointments }
            .filter { $0.registrar?.id == registrar.id }
    }

    func scheduledPatients(for date: Date, period: StatisticsPeriod) -> [Patient] {
        getSchedules(for: date, period: period).flatMap { $0.scheduledPatients }
    }

    func completedVisitPatients(for date: Date, period: StatisticsPeriod) -> [Patient] {
        getSchedules(for: date, period: period)
            .flatMap { $0.completedAppointments.compactMap { $0.patient } }
    }

    func attendance(for date: Date, period: StatisticsPeriod) -> [DayIndicator] {
        let groupedSchedules = Dictionary(
            grouping: getSchedules(for: date, period: period),
            by: { Calendar.current.startOfDay(for: $0.starting) }
        )
        var dayPatients = [Date: Int]()

        for day in period.days(for: date) {
            if let schedules = groupedSchedules[day] {
                let patients = schedules.flatMap { $0.completedAppointments.compactMap { $0.patient } }
                dayPatients[day] = Array(patients.uniqued()).count
            } else {
                dayPatients[day] = 0
            }
        }

        return dayPatients
            .map { DayIndicator(day: $0.key, indicator: $0.value) }
            .sorted(by: { $0.day < $1.day })
    }

    func patientsRevenue(for date: Date, period: StatisticsPeriod, maxCount: Int) -> [PatientRevenue] {
        let schedules = getSchedules(for: date, period: period)
        let patients = schedules
            .flatMap { $0.completedAppointments }
            .compactMap { $0.patient }
            .uniqued()

        var patientsRevenue: [PatientRevenue] = []

        for patient in patients {
            if let transactions = patient.transactions {
                let revenue = transactions.reduce(0.0) { $0 + $1.totalAmount }
                patientsRevenue.append(PatientRevenue(patient: patient, revenue: Int(revenue)))
            }
        }

        let sortedPatientsRevenue = patientsRevenue
            .sorted(by: { $0.revenue > $1.revenue })
            .prefix(maxCount)

        return Array(sortedPatientsRevenue)
    }
}

// MARK: - Private methods

private extension Ledger {
    func getSchedules(for date: Date, period: StatisticsPeriod) -> [DoctorSchedule] {
        let start = period.start(for: date)
        let end = period.end(for: date)
        let predicate = #Predicate<DoctorSchedule> { $0.starting > start && $0.ending < end }

        return database.getModels(predicate: predicate)
    }

    func getDoctor(by id: UUID) -> Doctor? {
        let predicate = #Predicate<Doctor> { $0.id == id }
        return database.getModel(predicate: predicate)
    }
}
