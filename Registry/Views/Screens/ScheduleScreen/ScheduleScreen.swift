//
//  ScheduleScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI
import SwiftData

struct ScheduleScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator
    @EnvironmentObject private var scheduleController: ScheduleController

    // MARK: -

    var body: some View {
        VStack {
            WeekdayPickerView(currentDate: $scheduleController.date)
                .padding(.bottom)

            if daySchedules.count == 0,
               scheduleController.date >= Calendar.current.startOfDay(for: .now) {
                emptyStateView
            } else {
                VStack {
                    HStack {
                        DatePickerDateView(date: scheduleController.date)

                        Spacer()

                        Button {
                            coordinator.present(.doctorSelection(date: scheduleController.date))
                        } label: {
                            Label("Добавить", systemImage: "plus.circle")
                        }
                        .disabled(scheduleController.date < Calendar.current.startOfDay(for: .now) || user.accessLevel < .registrar)
                    }
                    .padding(.bottom)

                    ScheduleChart(schedules: daySchedules, date: scheduleController.date)

                    HStack {
                        Spacer()

                        Button {
                            coordinator.push(.appointments)
                        } label: {
                            Label("Запись на прием", systemImage: "person.crop.rectangle.stack")
                        }
                        .padding(.top)
                        .buttonStyle(.bordered)
                        .disabled(daySchedules.isEmpty)
                    }
                }
                .padding()
                .background(
                    Color(.tertiarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ScheduleScreen()
        .environmentObject(Coordinator())
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension ScheduleScreen {
    var emptyStateView: some View {
        VStack {
            DatePickerDateView(date: scheduleController.date)
                .padding(.bottom, 16)

            Text("На выбранную дату нет созданных расписаний врачей")
                .foregroundColor(.secondary)

            if user.accessLevel >= .registrar {
                Button {
                    coordinator.present(.doctorSelection(date: scheduleController.date))
                } label: {
                    Text("Создать расписание")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Calculations

private extension ScheduleScreen {
    var daySchedules: [DoctorSchedule] {
        let startOfDay = Calendar.current.startOfDay(for: scheduleController.date)
        let endOfDay = Calendar.current.startOfDay(for: scheduleController.date.addingTimeInterval(86_400))
        let schedulesPredicate = #Predicate<DoctorSchedule> { $0.starting > startOfDay && $0.ending < endOfDay }
        let descriptor = FetchDescriptor(predicate: schedulesPredicate, sortBy: [SortDescriptor(\.starting, order: .forward)])

        guard let schedules = try? modelContext.fetch(descriptor) else { return [] }

        return schedules
    }
}
