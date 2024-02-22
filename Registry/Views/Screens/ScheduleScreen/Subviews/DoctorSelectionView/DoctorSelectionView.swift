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

    @Query private var doctors: [Doctor]

    let date: Date

    // MARK: - State

    @State private var searchText: String = ""
    @State private var createSchedule: Bool = false

    // MARK: -

    var body: some View {
        NavigationStack {
            let doctorsPredicate = #Predicate<Doctor> { doctor in
                searchText.isEmpty ? true :
                (doctor.secondName + " " + doctor.firstName + " " + doctor.patronymicName).localizedStandardContains(searchText)
            }
            let descriptor = FetchDescriptor(predicate: doctorsPredicate)

            if let searchedDoctors = try? modelContext.fetch(descriptor) {
                List(searchedDoctors) { doctor in
                    Button {
                        createSchedule = true
                    } label: {
                        DoctorView(doctor: doctor, presentation: .listRow)
                    }
                    .sheet(isPresented: $createSchedule) {
                        CreateDoctorScheduleView(doctor: doctor, date: date)
                    }
                }
                .listStyle(.inset)
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
                .sheetToolbar(title: "Выберите специалиста")
            }
        }
    }
}

#Preview {
    DoctorSelectionView(date: .now)
}
