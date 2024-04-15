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
    @State private var isLoadingPatientsForPeriod: Bool = true
    @State private var isLoadingPatientsCount: Bool = true

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
                isLoadingPatientsForPeriod = true
                Task {
                    fetchSchedules()
                }
            }

            LabeledContent("Пациентов за \(selectedPeriod.rawValue.lowercased())") {
                if isLoadingPatientsForPeriod {
                    CircularProgressView()
                        .padding(.horizontal)
                } else {
                    Text("\(scheduledPatients.count)")
                }
            }
            LabeledContent("Новые") {
                if isLoadingPatientsForPeriod {
                    CircularProgressView()
                        .padding(.horizontal)
                } else {
                    Text("\(newPatients.count)")
                }
            }
            LabeledContent("Всего в базе") {
                if isLoadingPatientsCount {
                    CircularProgressView()
                        .padding(.horizontal)
                } else {
                    Text("\(patientsCount)")
                }
            }
        }
        .task {
            Task {
                let patientsDescriptor = FetchDescriptor<Patient>()

                if let count = try? modelContext.fetchCount(patientsDescriptor) {
                    patientsCount = count
                }

                isLoadingPatientsCount = false
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
                .uniqued(on: { $0.id })
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

        isLoadingPatientsForPeriod = false
    }
}
