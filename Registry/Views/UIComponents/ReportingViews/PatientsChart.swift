//
//  PatientsChart.swift
//  Registry
//
//  Created by Николай Фаустов on 15.03.2024.
//

import SwiftUI
import SwiftData

struct PatientsChart: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var selectedPeriod: StatisticsPeriod = .day
    @State private var patientsCount: Int = 0
    @State private var schedules: [DoctorSchedule] = []

    // MARK: -

    var body: some View {
        Section("Пациенты") {
            Picker("Период", selection: $selectedPeriod) {
                ForEach(StatisticsPeriod.allCases) { period in
                    Text(period.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedPeriod) { _, newValue in
                Task {
                    fetchSchedules()
                }
            }

            LabeledContent("Пациентов за \(selectedPeriod.rawValue.lowercased())", value: "\(scheduledPatients.count)")
            LabeledContent("Новые", value: "\(newPatients.count)")
            Text("Всего в базе: \(patientsCount)")
        }
        .task {
            let patientsDescriptor = FetchDescriptor<Patient>()
            if let count = try? modelContext.fetchCount(patientsDescriptor) {
                patientsCount = count
            }

            Task {
                fetchSchedules()
            }
        }
    }
}

#Preview {
    PatientsChart()
        .environmentObject(Coordinator())
        .preferredColorScheme(.dark)
}

// MARK: - Claculations

private extension PatientsChart {
    var scheduledPatients: [Patient] {
        Array(
            schedules
                .flatMap { $0.scheduledPatients }
                .uniqued()
        )
    }

    var newPatients: [Patient] {
        scheduledPatients.filter { $0.isNewPatient(for: selectedPeriod) }
    }

    func fetchSchedules() {
        let start = selectedPeriod.start()
        let end = selectedPeriod.end()
        let schedulesPredicate = #Predicate<DoctorSchedule> { $0.starting > start && $0.ending < end }
        let descriptor = FetchDescriptor(predicate: schedulesPredicate)

        if let schedules = try? modelContext.fetch(descriptor) {
            self.schedules = schedules
        }
    }
}
