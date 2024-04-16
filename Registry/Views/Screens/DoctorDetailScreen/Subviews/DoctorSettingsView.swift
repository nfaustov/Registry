//
//  DoctorSettingsView.swift
//  Registry
//
//  Created by Николай Фаустов on 01.04.2024.
//

import SwiftUI

struct DoctorSettingsView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    @Bindable var doctor: Doctor

    // MARK: - State

    @State private var showPricelist: Bool = false
    @State private var isSearchingPricelistItem: Bool = false
    @State private var searchText: String = ""
    @State private var basicService: PricelistItem?
    @State private var salaryRate: Double = .zero

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

            if let rate = doctor.salary.rate {
                Section("Заработная плата") {
                    if user.accessLevel == .boss {
                        Stepper(
                            "Ставка \(Int(salaryRate * 100)) %",
                            value: $salaryRate,
                            in: 0.25...0.6,
                            step: 0.01
                        )
                        .onChange(of: salaryRate) { _, newValue in
                            doctor.salary = .pieceRate(rate: newValue)
                        }
                        .onAppear {
                            salaryRate = rate
                        }
                    } else {
                        Text("Ставка \(Int(salaryRate * 100)) %")
                    }
                }
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
