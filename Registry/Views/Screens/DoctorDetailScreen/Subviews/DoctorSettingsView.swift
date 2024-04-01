//
//  DoctorSettingsView.swift
//  Registry
//
//  Created by Николай Фаустов on 01.04.2024.
//

import SwiftUI

struct DoctorSettingsView: View {
    // MARK: - Dependencies

    @Bindable var doctor: Doctor

    // MARK: - State

    @State private var showPricelist: Bool = false
    @State private var isSearchingPricelistItem: Bool = false
    @State private var searchText: String = ""
    @State private var basicService: PricelistItem?

    // MARK: -

    var body: some View {
        Form {
            Section {
                Picker("Специальность", selection: $doctor.department) {
                    ForEach(Department.allCases) { department in
                        Text(department.specialization)
                    }
                }

                Button {
                    showPricelist = true
                } label: {
                    LabeledContent(doctor.basicService?.title ?? "Базовая услуга") {
                        Image(systemName: "chevron.right")
                    }
                }
                .tint(.primary)
            } header: {
                Text("Специализация")
            }

            Section {
                DurationLabel(doctor.serviceDuration, systemImage: "clock")
                Slider(
                    value: $doctor.serviceDuration,
                    in: 300...7200,
                    step: 300
                )
            } header: {
                Text("Прием пациента")
            }

            Section {
                Stepper(value: $doctor.defaultCabinet, in: 1...3) {
                    Text("\(doctor.defaultCabinet)")
                }
            } header: {
                Text("Кабинет (по умолчанию)")
            }
        }
        .sheet(isPresented: $showPricelist) {
            NavigationStack {
                PricelistView(
                    filterText: searchText,
                    selectedPricelistItem: $basicService,
                    isSearching: $isSearchingPricelistItem
                )
                .listStyle(.plain)
                .searchable(
                    text: $searchText,
                    isPresented: $isSearchingPricelistItem,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
                .sheetToolbar(title: "Выберите услугу")
                .onChange(of: basicService) { _, newValue in
                    doctor.basicService = basicService?.short
                    showPricelist = false
                }
            }
        }
    }
}

#Preview {
    DoctorSettingsView(doctor: ExampleData.doctor)
}
