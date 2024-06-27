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
    @State private var salaryRate: Double
    @State private var minSalaryAmount: Double
    @State private var monthlyAmount: Int
    @State private var salary: Salary


    // MARK: -

    init(doctor: Doctor) {
        self.doctor = doctor
        _salary = State(initialValue: doctor.doctorSalary)
        _salaryRate = State(initialValue: doctor.doctorSalary.rate ?? 0.4)
        _minSalaryAmount = State(initialValue: doctor.doctorSalary.minAmount ?? 0)
        _monthlyAmount = State(initialValue: doctor.doctorSalary.monthlyAmount ?? 0)
    }

    var body: some View {
        Form {
            Section("Специализация") {
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
            }

            Section("Прием пациента") {
                DurationLabel(doctor.serviceDuration, systemImage: "clock")
                Slider(
                    value: $doctor.serviceDuration,
                    in: 300...7200,
                    step: 300
                )
            }

            Section("Кабинет (по умолчанию)") {
                Stepper(value: $doctor.defaultCabinet, in: 1...3) {
                    Text("\(doctor.defaultCabinet)")
                }
            }

            if user.accessLevel == .boss {
                Section("Заработная плата") {
                    Menu(doctor.doctorSalary.title) {
                        ForEach(Salary.allCases, id: \.self) { type in
                            Button(type.title) {
                                withAnimation {
                                    doctor.doctorSalary = type
                                }
                            }
                        }
                    }
                    
                    if let rate = doctor.doctorSalary.rate {
                        Stepper(
                            "Ставка \(Int(rate * 100)) %",
                            value: $salaryRate,
                            in: 0.25...0.6,
                            step: 0.01
                        )
                        .onChange(of: salaryRate) { _, newValue in
                            doctor.doctorSalary = .pieceRate(rate: newValue)
                        }
                        
                        LabeledContent("Минимальная оплата") {
                            TextField("Минимальная оплата", value: $minSalaryAmount, format: .number)
                        }
                        .onChange(of: minSalaryAmount) { _, newValue in
                            doctor.doctorSalary = .pieceRate(rate: salaryRate, minAmount: newValue)
                        }
                    } else if doctor.doctorSalary.monthlyAmount != nil {
                        TextField("Ежемесячная оплата", value: $monthlyAmount, format: .number)
                            .onChange(of: monthlyAmount) { _, newValue in
                                doctor.doctorSalary = .monthly(amount: newValue)
                            }
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
                .sheetToolbar("Выберите услугу")
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
