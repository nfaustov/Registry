//
//  DoctorVacationView.swift
//  Registry
//
//  Created by Николай Фаустов on 17.05.2024.
//

import SwiftUI

struct DoctorVacationView: View {
    // MARK: - Dependencies

    let doctor: Doctor

    // MARK: - State

    @State private var selection: Set<DateComponents> = []

    // MARK: -

    var body: some View {
        Form {
            Section("Запланированные отпуска") {
                ForEach(doctor.vacationSchedule, id: \.self) { vacation in
                    Text("\(DateFormat.date.string(from: vacation.start)) - \(DateFormat.date.string(from: vacation.end))")
                    Text("\(vacation.duration / 86_400) дней")
                }
            }

            Section {
                let startOfYearComponent = Calendar.current.dateComponents([.year], from: .now)
                let startOfYear = Calendar.current.date(from: startOfYearComponent)!
                let endOFYearComponent = Calendar.current.dateComponents([.year], from: .now.addingTimeInterval(86_400 * 366))
                let endOfYear = Calendar.current.date(from: endOFYearComponent)!

                MultiDatePicker("Выберите даты", selection: $selection, in: startOfYear..<endOfYear)

                Button("Добавить отпуск") {
//                    doctor.vacationSchedule.append(DateInterval(start: Calendar.current.date(from: selection[0])!, end: Calendar.current.date(from: selection[1])!))
                }
                .disabled(selection.count != 2)
            }
        }
    }
}

#Preview {
    DoctorVacationView(doctor: ExampleData.doctor)
}
