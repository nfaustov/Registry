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

    @State private var starting: Date = .now
    @State private var ending: Date = .now

    // MARK: -

    var body: some View {
        Form {
            let plannedVacations = doctor.vacationSchedule.filter { $0.end > .now }
            if !plannedVacations.isEmpty {
                Section("Запланированные отпуска") {
                    ForEach(plannedVacations, id: \.self) { vacation in
                        HStack {
                            LabeledContent(
                                "\(DateFormat.dateTime.string(from: vacation.start)) - \(DateFormat.dateTime.string(from: vacation.end))",
                                value: "\(Int(round(vacation.duration / 86_400))) дней"
                            )

                            Button(role: .destructive) {
                                withAnimation {
                                    doctor.vacationSchedule.removeAll(where: { $0 == vacation })
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }

            Section {
                let startOfYearComponent = Calendar.current.dateComponents([.year], from: .now)
                let startOfYear = Calendar.current.date(from: startOfYearComponent)!
                let endOFYearComponent = Calendar.current.dateComponents([.year], from: .now.addingTimeInterval(86_400 * 366))
                let endOfYear = Calendar.current.date(from: endOFYearComponent)!

                DatePicker("Начало", selection: $starting, in: startOfYear...endOfYear, displayedComponents: .date)
                DatePicker("Конец", selection: $ending, in: starting...endOfYear, displayedComponents: .date)

                Button("Добавить отпуск") {
                    let startOfStarting = Calendar.current.startOfDay(for: starting)
                    let endOfEnding = Calendar.current.startOfDay(for: ending).addingTimeInterval(86_399)
                    withAnimation {
                        doctor.vacationSchedule.append(DateInterval(start: startOfStarting, end: endOfEnding))
                    }
                }
                .disabled(starting == .now && ending == .now)
            }
        }
    }
}

#Preview {
    DoctorVacationView(doctor: ExampleData.doctor)
}
