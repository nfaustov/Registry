//
//  AppointmentsRegisterScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 23.02.2024.
//

import SwiftUI
import SwiftData

struct AppointmentsRegisterScreen: View {
    // MARK: - Dependensies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator
    @EnvironmentObject private var scheduleController: ScheduleController

    // MARK: -

    var body: some View {
        HStack {
            SchedulesListView(schedules: daySchedules)
                .frame(width: 360)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                if let doctorSchedule = scheduleController.selectedSchedule {
                    DoctorScheduleHeaderView(doctorSchedule: doctorSchedule, deleteSchedule: {
                        modelContext.delete(doctorSchedule)
                        scheduleController.selectedSchedule = daySchedules.first

                        if scheduleController.selectedSchedule == nil {
                            coordinator.pop()
                        }
                    })
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 182, alignment: .leading)

                    Divider()

                    AppointmentsListView(schedule: doctorSchedule)
                }
            }
            .disabled(user.accessLevel < .registrar)
        }
        .navTitle(
            title: "Запись на прием",
            subTitle: DateFormat.weekDay.string(from: scheduleController.date)
        )
        .onAppear {
            if scheduleController.selectedSchedule == nil {
                scheduleController.selectedSchedule = daySchedules.first
            }
        }
    }
}

#Preview {
    AppointmentsRegisterScreen()
        .environmentObject(Coordinator())
        .environmentObject(ScheduleController())
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Calculations

private extension AppointmentsRegisterScreen {
    var daySchedules: [DoctorSchedule] {
        let startOfDay = Calendar.current.startOfDay(for: scheduleController.date)
        let endOfDay = Calendar.current.startOfDay(for: scheduleController.date.addingTimeInterval(86_400))
        let schedulesPredicate = #Predicate<DoctorSchedule> { $0.starting > startOfDay && $0.ending < endOfDay }
        let descriptor = FetchDescriptor(predicate: schedulesPredicate, sortBy: [SortDescriptor(\.starting, order: .forward), SortDescriptor(\.ending, order: .forward)])

        guard let schedules = try? modelContext.fetch(descriptor) else { return [] }

        return schedules
    }
}
