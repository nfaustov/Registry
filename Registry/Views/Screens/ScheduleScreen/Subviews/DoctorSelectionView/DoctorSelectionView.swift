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

    // MARK: -

    var body: some View {
        NavigationStack {
            if let searchedDoctors = try? modelContext.fetch(searchDescriptor) {
                List(searchedDoctors) { doctor in
                    Button {
                        selectedDoctor = doctor
                    } label: {
                        DoctorView(doctor: doctor, presentation: .listRow)
                    }
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
                .sheetToolbar("Выберите специалиста")
            }
        }
    }
}

#Preview {
    DoctorSelectionView(date: .now)
}

// MARK: - Calculations

private extension DoctorSelectionView {
    var searchDescriptor: FetchDescriptor<Doctor> {
        let predicate = #Predicate<Doctor> { doctor in
            searchText.isEmpty ? true :
            doctor.secondName.localizedStandardContains(searchText) ||
            doctor.firstName.localizedStandardContains(searchText) ||
            doctor.patronymicName.localizedStandardContains(searchText)
        }
        let descriptor = FetchDescriptor<Doctor>(predicate: predicate)

        return descriptor
    }
}
