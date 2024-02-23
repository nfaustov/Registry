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

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var date: Date = .now

    // MARK: -

    var body: some View {
        VStack {
            WeekdayPickerView(currentDate: $date)
                .padding(.bottom)

            if let daySchedules = try? modelContext.fetch(descriptor) {
                if daySchedules.count == 0,
                   date >= Calendar.current.startOfDay(for: .now) {
                    emptyStateView
                } else {
                    VStack {
                        HStack {
                            DatePickerDateView(date: date)

                            Spacer()

                            Button {
                                coordinator.present(.doctorSelection(date: date))
                            } label: {
                                Label("Добавить", systemImage: "plus.circle")
                            }
                            .disabled(date < Calendar.current.startOfDay(for: .now))
                        }
                        .padding(.bottom)

                        ScheduleChart(schedules: daySchedules, date: date)

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
            DatePickerDateView(date: date)
                .padding(.bottom, 16)

            Text("На выбранную дату нет созданных расписаний врачей")
                .foregroundColor(.secondary)

            Button {
                coordinator.present(.doctorSelection(date: date))
            } label: {
                Text("Создать расписание")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Calculations

private extension ScheduleScreen {
    var descriptor: FetchDescriptor<DoctorSchedule> {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.startOfDay(for: date.addingTimeInterval(86_400))
        let schedulesPredicate = #Predicate<DoctorSchedule> { schedule in
            schedule.starting > startOfDay && schedule.ending < endOfDay
        }
        let descriptor = FetchDescriptor(predicate: schedulesPredicate)

        return descriptor
    }
}
