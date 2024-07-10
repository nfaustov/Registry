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

    // MARK: - State

    @State private var daySchedules: [DoctorSchedule] = []

    // MARK: -

    var body: some View {
        HStack {
            SchedulesListView(schedules: daySchedules)
                .frame(width: 360)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                if let doctorSchedule = scheduleController.selectedSchedule {
                    DoctorScheduleHeaderView(doctorSchedule: doctorSchedule, deleteSchedule: {
                        scheduleController.selectedSchedule = daySchedules.first(where: { $0 != doctorSchedule })
                        modelContext.delete(doctorSchedule)

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
            daySchedules = schedules

            if scheduleController.selectedSchedule == nil {
                scheduleController.selectedSchedule = daySchedules.first
            }
        }
        .onChange(of: scheduleController.date) {
            withAnimation {
                daySchedules = schedules
            }

            scheduleController.selectedSchedule = daySchedules.first
        }
//        .gesture(
//            DragGesture()
//                .onEnded { value in
//                    if value.translation.width < -300 {
//                        if let date = nextDateWithSchedule {
//                            scheduleController.date = date
//                        }
//                    } else if value.translation.width > 300 {
//                        if let date = previousDateWithSchedule {
//                            scheduleController.date = date
//                        }
//                    }
//                }
//        )
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
    var schedules: [DoctorSchedule] {
        let startOfDay = Calendar.current.startOfDay(for: scheduleController.date)
        let endOfDay = Calendar.current.startOfDay(for: scheduleController.date.addingTimeInterval(86_400))
        let predicate = #Predicate<DoctorSchedule> { $0.starting > startOfDay && $0.ending < endOfDay }
        let database = DatabaseController(modelContext: modelContext)

        return database.getModels(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.starting, order: .forward),
                SortDescriptor(\.ending, order: .forward)
            ]
        )
    }

    var nextDateWithSchedule: Date? {
        let referrenceDate = Calendar.current.startOfDay(for: scheduleController.date).addingTimeInterval(86_400)
        let predicate = #Predicate<DoctorSchedule> { $0.starting > referrenceDate }
        let database = DatabaseController(modelContext: modelContext)
        let schedule = database.getModel(
            predicate: predicate,
            sortBy: [SortDescriptor(\.starting, order: .forward)]
        )

        return schedule?.starting
    }

    var previousDateWithSchedule: Date? {
        let referrenceDate = Calendar.current.startOfDay(for: scheduleController.date)
        let predicate = #Predicate<DoctorSchedule> { $0.starting < referrenceDate }
        let database = DatabaseController(modelContext: modelContext)
        let schedule = database.getModel(
            predicate: predicate,
            sortBy: [SortDescriptor(\.starting, order: .reverse)]
        )

        return schedule?.starting
    }
}
