//
//  DoctorFutureSchedulesView.swift
//  Registry
//
//  Created by Николай Фаустов on 26.02.2024.
//

import SwiftUI
import SwiftData

struct DoctorFutureSchedulesView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var scheduleController: ScheduleController

    let doctorSchedule: DoctorSchedule

    // MARK: -

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground)
                if futureSchedules.isEmpty {
                    VStack {
                        Spacer()

                        Text("У выбранного врача пока нет других расписаний.")

                        Spacer()
                    }
                } else {
                    ScrollView(.vertical) {
                        VStack {
                            ForEach(futureSchedules) { schedule in
                                scheduleView(schedule)
                                    .onTapGesture {
                                        if schedule.id != doctorSchedule.id {
                                            scheduleController.date = schedule.starting
                                            scheduleController.selectedSchedule = schedule
                                        }
                                        dismiss()
                                    }
                            }
                        }
                        .padding(.top)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
            .sheetToolbar(title: "Расписания врача", subtitle: doctorSchedule.doctor?.initials ?? "")
        }
    }
}

#Preview {
    DoctorFutureSchedulesView(doctorSchedule: ExampleData.doctorSchedule)
        .environmentObject(ScheduleController())
}

// MARK: - Subviews

private extension DoctorFutureSchedulesView {
    func scheduleView(_ schedule: DoctorSchedule) -> some View {
        VStack(alignment: .leading) {
            HStack {
                DatePickerDateView(date: schedule.starting)
                Spacer()
            }

            Text(scheduleBounds(schedule))
        }
        .padding()
        .background(doctorSchedule.id == schedule.id ? .blue.opacity(0.2) : Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

// MARK: - Calculations

private extension DoctorFutureSchedulesView {
    var futureSchedules: [DoctorSchedule] {
        let today = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<DoctorSchedule> { $0.starting > today }
        let descriptor = FetchDescriptor<DoctorSchedule>(predicate: predicate, sortBy: [SortDescriptor(\.starting, order: .forward)])

        guard let schedules = try? modelContext.fetch(descriptor) else { return [] }

        return schedules.filter { $0.doctor == doctorSchedule.doctor }
    }

    func scheduleBounds(_ schedule: DoctorSchedule) -> String {
        DateFormatter.shared.dateFormat = "H:mm"
        let starting = DateFormatter.shared.string(from: schedule.starting)
        let ending = DateFormatter.shared.string(from: schedule.ending)
        return "\(starting) - \(ending)"
    }
}
