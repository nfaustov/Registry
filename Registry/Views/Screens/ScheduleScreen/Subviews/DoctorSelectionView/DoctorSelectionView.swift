//
//  DoctorSelectionView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI
import SwiftData

struct DoctorSelectionView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let date: Date

    // MARK: - State

    @State private var searchText: String = ""
    @State private var selectedDoctor: Doctor?
    @State private var doctors: [Doctor] = []

    // MARK: -

    var body: some View {
        NavigationStack {
            List(doctors) { doctor in
                Button {
                    selectedDoctor = doctor
                } label: {
                    DoctorView(doctor: doctor, presentation: .listRow)
                }
                .disabled(alreadyHasTodaySchedule(doctor))
            }
            .listStyle(.inset)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .sheet(item: $selectedDoctor) {
                CreateDoctorScheduleView(doctor: $0, date: date) {
                    dismiss()
                }
            }
            .task {
                let predicate = #Predicate<Doctor> { doctor in
                    searchText.isEmpty ? true :
                    doctor.secondName.localizedStandardContains(searchText) ||
                    doctor.firstName.localizedStandardContains(searchText) ||
                    doctor.patronymicName.localizedStandardContains(searchText)
                }
                let descriptor = FetchDescriptor<Doctor>(predicate: predicate)

                if let searchedDoctors = try? modelContext.fetch(descriptor) {
                    doctors = searchedDoctors
                        .sorted(by: { $0.schedules?.count ?? 0 > $1.schedules?.count ?? 0 })
                        .sorted(by: { !alreadyHasTodaySchedule($0) && alreadyHasTodaySchedule($1) })
                }
            }
            .sheetToolbar("Выберите специалиста")
        }
    }
}

#Preview {
    DoctorSelectionView(date: .now)
}

// MARK: - Calculations

private extension DoctorSelectionView {
    func alreadyHasTodaySchedule(_ doctor: Doctor) -> Bool {
        guard let schedules = doctor.schedules else { return false }

        return !schedules
            .filter { Calendar.current.isDate(date, inSameDayAs: $0.starting) }
            .isEmpty
    }
}
