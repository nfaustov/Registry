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
    @State private var minSalaryAmount: Double = .zero
    @State private var salaryType: Salary = .pieceRate()
    @State private var monthlyAmount: Int = 0

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
                    LabeledContent(doctor.defaultPricelistItem?.title ?? "Базовая услуга") {
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

            Section("Заработная плата") {
                if user.accessLevel == .boss {
                    Picker("Заработная плата", selection: $salaryType) {
                        ForEach(Salary.allCases, id: \.self) { type in
                            Text(type.title)
                        }
                    }
                    .onChange(of: salaryType) { _, newValue in
                        doctor.doctorSalary = salaryType
                    }
                }

                if let rate = doctor.doctorSalary.rate {
                    if user.accessLevel == .boss {
                        Stepper(
                            "Ставка \(Int(salaryRate * 100)) %",
                            value: $salaryRate,
                            in: 0.25...0.6,
                            step: 0.01
                        )
                        .onChange(of: salaryRate) { _, newValue in
                            doctor.doctorSalary = .pieceRate(rate: newValue, minAmount: minSalaryAmount)
                        }
                        .onAppear {
                            salaryRate = rate
                        }

                        LabeledContent("Минимальная оплата") {
                            TextField("Минимальная оплата", value: $minSalaryAmount, format: .number)
                        }
                        .onChange(of: minSalaryAmount) { _, newValue in
                            doctor.doctorSalary = .pieceRate(rate: salaryRate, minAmount: newValue)
                        }
                        .onAppear {
                            minSalaryAmount = doctor.doctorSalary.minAmount ?? 0
                        }
                    } else {
                        LabeledContent("Ставка", value: "\(Int(rate * 100)) %")

                        if let minAmount = doctor.doctorSalary.minAmount {
                            LabeledContent("Минимальная оплата", value: "\(Int(minAmount)) ₽")
                        }
                    }
                } else if let monthlySalary = doctor.doctorSalary.monthlyAmount {
                    if user.accessLevel == .boss {
                        TextField("Ежемесячная оплата", value: $monthlyAmount, format: .number)
                            .onChange(of: monthlyAmount) { _, newValue in
                                doctor.doctorSalary = .monthly(amount: newValue)
                            }
                            .onAppear {
                                monthlyAmount = monthlySalary
                            }
                    }
                }
            }
            .onAppear {
                salaryType = doctor.doctorSalary
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
                    doctor.defaultPricelistItem = basicService
                    showPricelist = false
                }
            }
        }
    }
}

#Preview {
    DoctorSettingsView(doctor: ExampleData.doctor)
}
