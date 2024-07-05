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

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar(identifier: .iso8601)

    // MARK: - State

    @State private var futureSchedules: [DoctorSchedule] = []

    // MARK: -

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekDay in
                        Text(weekDay)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(days) { day in
                        if let schedule = schedule(on: day) {
                            VStack {
                                Text(day.dayLabel)
                                    .fontWeight(.medium)
                                    .foregroundStyle(day.isToday ? .orange : .primary)
                                Text(scheduleBounds(schedule))
                                    .font(.caption)
                                    .padding(.vertical, 4)
                            }
                            .padding(8)
                            .background(
                                doctorSchedule.id == schedule.id ? .blue.opacity(0.2) : Color(.systemFill),
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                            .onTapGesture {
                                if schedule.id != doctorSchedule.id {
                                    scheduleController.date = day.date
                                    scheduleController.selectedSchedule = schedule
                                }

                                dismiss()
                            }
                        } else {
                            Text(day.dayLabel)
                                .padding(8)
                        }
                    }
                }

                Spacer()
            }
            .padding()
            .onAppear {
                let today = calendar.startOfDay(for: .now)
                let predicate = #Predicate<DoctorSchedule> { $0.starting > today }
                let database = DatabaseController(modelContext: modelContext)
                futureSchedules = database.getModels(
                    predicate: predicate,
                    sortBy: [SortDescriptor(\.starting, order: .forward)]
                ).filter { $0.doctor == doctorSchedule.doctor }
            }
            .sheetToolbar("Расписание врача", subtitle: doctorSchedule.doctor?.initials ?? "")
        }
    }
}

#Preview {
    DoctorFutureSchedulesView(doctorSchedule: ExampleData.doctorSchedule)
        .environmentObject(ScheduleController())
}

// MARK: - Calculations

private extension DoctorFutureSchedulesView {
    var days: [WeekDay] {
        guard let firstSchedule = futureSchedules.first,
              let lastSchedule = futureSchedules.last else { return [] }

        let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: firstSchedule.starting)?.start
        let endOfWeek = calendar.dateInterval(of: .weekOfMonth, for: lastSchedule.starting)?.end
        let days = calendar.dateComponents(
            [.day],
            from: startOfWeek!,
            to: endOfWeek!
        ).day!

        return (0..<max(14, days)).map {
            WeekDay(date: calendar.date(byAdding: .day, value: $0, to: startOfWeek!)!)
        }
    }

    func schedule(on day: WeekDay) -> DoctorSchedule? {
        futureSchedules.first(where: { calendar.isDate(day.date, inSameDayAs: $0.starting) })
    }

    func scheduleBounds(_ schedule: DoctorSchedule) -> String {
        DateFormatter.shared.dateFormat = "H:mm"
        let starting = DateFormatter.shared.string(from: schedule.starting)
        let ending = DateFormatter.shared.string(from: schedule.ending)
        return "\(starting) - \(ending)"
    }
}
