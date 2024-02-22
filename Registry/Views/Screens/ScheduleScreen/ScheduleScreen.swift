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

    @EnvironmentObject private var coordinator: Coordinator

    @Query private var schedules: [DoctorSchedule]

    // MARK: - State

    @State private var date: Date = .now

    // MARK: -

    init() {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.startOfDay(for: date.addingTimeInterval(86_400))
        _schedules = Query(
            filter: #Predicate { $0.starting > startOfDay && $0.ending < endOfDay },
            sort: \.starting,
            order: .forward
        )
    }

    var body: some View {
        VStack {
            WeekdayPickerView(currentDate: $date)
                .padding(.bottom)

            if schedules.count == 0,
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

                    ScheduleChart(schedules: schedules, date: date)

                    HStack {
                        Spacer()

                        Button {
                            coordinator.push(.appointments)
                        } label: {
                            Label("Запись на прием", systemImage: "person.crop.rectangle.stack")
                        }
                        .padding(.top)
                        .buttonStyle(.bordered)
                        .disabled(schedules.isEmpty)
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
