//
//  Ledger+Patients.swift
//  Registry
//
//  Created by Николай Фаустов on 07.06.2024.
//

import Foundation
import SwiftData

extension Ledger {
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
