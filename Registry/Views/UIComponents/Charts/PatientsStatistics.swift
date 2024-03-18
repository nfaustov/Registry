//
//  PatientsStatistics.swift
//  Registry
//
//  Created by Николай Фаустов on 15.03.2024.
//

import SwiftUI
import SwiftData

struct PatientsStatistics: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var selectedPeriod: StatisticsPeriod = .day

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Пациенты")
                    .font(.title)

                Spacer()

                HStack {
                    ForEach (StatisticsPeriod.allCases) { period in
                        Text(period.rawValue)
                            .foregroundStyle(period == selectedPeriod ? .primary : .secondary)
                            .onTapGesture {
                                selectedPeriod = period
                            }
                    }
                }
            }
            .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("\(scheduledPatients.count)")
                        .font(.largeTitle)
                    Spacer()
                    Text("Новые \(newPatients.count)")
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geometry in
                    let width = geometry.size.width - 2
                    let proportion = scheduledPatients.count > 0 ? CGFloat(newPatients.count / scheduledPatients.count) : 0

                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .frame(width: (1 - proportion) * width, height: 6)
                            .foregroundStyle(.blue)

                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .frame(width: proportion * width, height: 6)
                            .foregroundStyle(.teal)
                    }
                }
            }
            .frame(height: 80)
        }
    }
}

#Preview {
    PatientsStatistics()
        .preferredColorScheme(.dark)
}

// MARK: - Claculations

private extension PatientsStatistics {
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

    var schedules: [DoctorSchedule] {
        let start = selectedPeriod.start
        let end = selectedPeriod.end
        let schedulesPredicate = #Predicate<DoctorSchedule> { $0.starting > start && $0.ending < end }
        let descriptor = FetchDescriptor(predicate: schedulesPredicate)

        guard let schedules = try? modelContext.fetch(descriptor) else { return [] }

        return schedules
    }
}
