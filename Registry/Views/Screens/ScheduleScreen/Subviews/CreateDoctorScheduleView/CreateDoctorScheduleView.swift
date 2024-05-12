//
//  CreateDoctorScheduleView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct CreateDoctorScheduleView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let doctor: Doctor
    let date: Date
    var onConfirm: () -> Void
    
    // MARK: - State
    
    @State private var startingDate: Date = .now
    @State private var endingDate: Date = .now
    @State private var cabinet: Int
    
    // MARK: -
    
    init(doctor: Doctor, date: Date, onConfirm: @escaping () -> Void) {
        self.doctor = doctor
        self.date = date
        self.onConfirm = onConfirm
        _cabinet = State(initialValue: doctor.defaultCabinet)

        UIDatePicker.appearance().minuteInterval = Int(doctor.serviceDuration / 60)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DateText(date, format: .weekDay)
                } header: {
                    Text("Дата")
                }

                Section {
                    if doctor.department == .procedure {
                        scheduleBoundsText(for: .starting)
                        scheduleBoundsText(for: .ending)
                    } else {
                        scheduleBoundsPicker(for: .starting)
                        scheduleBoundsPicker(for: .ending)
                    }
                } header: {
                    Text("Время")
                }

                Section {
                    if doctor.department == .procedure {
                        cabinetView
                    } else {
                        Stepper(value: $cabinet, in: 1...3) {
                            cabinetView
                        }
                    }
                } header: {
                    Text("Кабинет")
                }
            }
            .sheetToolbar(
                doctor.fullName,
                disabled: endingDate.timeIntervalSince(startingDate) < doctor.serviceDuration
            ) {
                let schedule = DoctorSchedule(
                    doctor: doctor,
                    cabinet: cabinet, starting: startingDate,
                    ending: endingDate
                )
                modelContext.insert(schedule)
                onConfirm()
            }
            .onAppear {
                if doctor.department == .procedure {
                    startingDate = workingHours.start
                    endingDate = workingHours.end
                } else {
                    startingDate = min(
                        max(workingHours.start, Calendar.current.date(bySetting: .minute, value: 0, of: .now) ?? .now),
                        workingHours.end.addingTimeInterval(-doctor.serviceDuration)
                    )
                    endingDate = startingDate.addingTimeInterval(doctor.serviceDuration)
                }
            }
        }
    }
}

#Preview {
    CreateDoctorScheduleView(doctor: ExampleData.doctor, date: .now, onConfirm: { })
}

// MARK: - Subviews

private extension CreateDoctorScheduleView {
    var cabinetView: some View {
        HStack {
            if cabinet == doctor.defaultCabinet {
                Text("\(cabinet)")
                Text("(по умолчанию)")
                    .foregroundColor(.secondary)
            } else {
                Text("\(cabinet)")
            }
        }
    }

    func scheduleBoundsText(for edge: ScheduleEdge) -> some View {
        HStack {
            Text(edge == .starting ? "Начало": "Конец")
            Spacer()
            DateText(edge == .starting ? workingHours.start : workingHours.end, format: .time)
                .foregroundStyle(.secondary)
        }
    }

    func scheduleBoundsPicker(for edge: ScheduleEdge) -> some View {
        DatePicker(
            edge == .starting ? "Начало": "Конец",
            selection: edge == .starting ? $startingDate : $endingDate,
            in: edge == .starting ?
                workingHours.range :
                min(startingDate.addingTimeInterval(doctor.serviceDuration), workingHours.end.addingTimeInterval(-doctor.serviceDuration))...workingHours.end,
            displayedComponents: .hourAndMinute
        )
    }
}

// MARK: - Calculations

private extension CreateDoctorScheduleView {
    var workingHours: WorkingHours {
        WorkingHours(for: date)
    }
}

public enum ScheduleEdge {
    case starting, ending
}
