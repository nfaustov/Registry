//
//  DoctorsScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI
import SwiftData

struct DoctorsScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var selectedDoctor: Doctor?
    @State private var searchText: String = ""

    // MARK: -

    var body: some View {
        ScrollView {
            ForEach(Department.allCases) { department in
                let doctorsPredicate = #Predicate<Doctor> { doctor in
                    doctor.department == department &&
                    (searchText.isEmpty ? true : doctor.fullName.contains(searchText))
                }
                let descriptor = FetchDescriptor(predicate: doctorsPredicate)

                if let specializationDoctors = try? modelContext.fetch(descriptor) {
                    let doctorsCount = specializationDoctors.count
                    let rows = doctorsCount % Constant.maxRowItems > 0 ? (doctorsCount / Constant.maxRowItems) + 1 : doctorsCount / Constant.maxRowItems

                    if !specializationDoctors.isEmpty {
                        VStack(alignment: .leading) {
                            Section {
                                Grid {
                                    ForEach(0..<rows, id: \.self) { row in
                                        GridRow {
                                            ForEach(specializationDoctors[rangeInRow(row, rowItems: doctorsCount)]) { doctor in
                                                Button {
                                                    coordinator.push(.doctorDetail(doctor: doctor))
                                                } label: {
                                                    DoctorView(doctor: doctor, presentation: .gridItem)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            } header: {
                                Text(department.specialization)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding([.top, .leading], 32)
                                Divider()
                                    .padding(.horizontal, 32)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
        }
        .catalogToolbar {
            coordinator.present(.createDoctor)
        }
    }
}

#Preview {
    NavigationStack {
        DoctorsScreen()
            .navigationTitle("Специалисты")
    }
    .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Calculations

private extension DoctorsScreen {
    func rangeInRow(_ row: Int, rowItems: Int) -> Range<Int> {
        let start = row * Constant.maxRowItems
        let end = min(Constant.maxRowItems * (row + 1), rowItems)
        return start..<end
    }
}

// MARK: - Constants

private extension DoctorsScreen {
    enum Constant {
        static let maxRowItems = 4
    }
}
