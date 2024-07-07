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
    private let calendar = Calendar.current

    // MARK: - State

    @State private var futureSchedules: [DoctorSchedule] = []

    // MARK: -

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    ForEach(symbols, id: \.self) { weekDay in
                        Text(weekDay.localizedCapitalized)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(days) { day in
                        if let schedule = schedule(on: day) {
                            VStack {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(day.dayLabel)
                                        .font(.title)
                                        .foregroundStyle(day.isToday ? .orange : .primary)
                                    Text(day.monthLabel)
                                        .font(.caption)
                                        .foregroundStyle(day.isToday ? .orange : .primary)
                                }

                                Text(scheduleBounds(schedule))
                                    .font(.caption2)
                                    .padding(.bottom, 4)
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
                                .font(.title2)
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
    var symbols: [String] {
        var symbols = calendar.shortWeekdaySymbols
        let sunday = symbols.removeFirst()
        symbols.append(sunday)

        return symbols
    }

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

        return (0..<max(28, days)).map {
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
