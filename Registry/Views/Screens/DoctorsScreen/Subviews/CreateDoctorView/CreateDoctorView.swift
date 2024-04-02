//
//  CreateDoctorView.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI
import PhotosUI

struct CreateDoctorView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext
    @Environment(\.user) private var user

    @StateObject private var viewModel = PhotosPickerViewModel()

    // MARK: - State

    @State private var addBasicService: Bool = false
    @State private var searchText: String = ""
    @State private var secondNameText: String = ""
    @State private var firstNameText: String = ""
    @State private var patronymicNameText: String = ""
    @State private var phoneNumberText: String = ""
    @State private var birthDate: Date = .now
    @State private var department: Department = .gynecology
    @State private var basicService: PricelistItem?
    @State private var serviceDuration: TimeInterval = 300
    @State private var defaultCabinet: Int = 1
    @State private var infoText: String = ""
    @State private var salary: Salary = .pieceRate()
    @State private var perVisitAmount: Int = 0
    @State private var salaryRate: Double = 0.4
    @State private var isSearching: Bool = false
    @State private var userLevel: UserAccessLevel = .doctor

    // MARK: -

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 150)
                            .cornerRadius(16)
                    }
                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                        Text("Выберите фото")
                    }
                } header: {
                    Text("Фото")
                }
                .listRowSeparator(.hidden)

                Section {
                    TextField("Фамилия", text: $secondNameText)
                    TextField("Имя", text: $firstNameText)
                    TextField("Отчество", text: $patronymicNameText)
                } header: {
                    Text("Ф.И.О.")
                }

                Section {
                    PhoneNumberTextField(text: $phoneNumberText)
                } header: {
                    Text("Номер телефона")
                }

                Section {
                    DatePicker(
                        "Дата рождения",
                        selection: $birthDate,
                        in: ...Date.now.addingTimeInterval(-567_468_000),
                        displayedComponents: .date
                    )
                } header: {
                    Text("Дата рождения")
                }

                Section {
                    Picker("Специальность", selection: $department) {
                        ForEach(Department.allCases) { department in
                            Text(department.specialization)
                        }
                    }
                    Button {
                        addBasicService = true
                    } label: {
                        HStack {
                            Text(basicService?.title ?? "Базовая услуга")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                    .tint(.primary)
                } header: {
                    Text("Специализация")
                }

                Section {
                    DurationLabel(serviceDuration, systemImage: "clock")
                    Slider(
                        value: $serviceDuration,
                        in: 300...7200,
                        step: 300
                    )
                } header: {
                    Text("Прием пациента")
                }

                Section {
                    Stepper(value: $defaultCabinet, in: 1...3) {
                        Text("\(defaultCabinet)")
                    }
                } header: {
                    Text("Кабинет (по умолчанию)")
                }

                Section {
                    Picker("Тип оплаты", selection: $salary) {
                        ForEach(Salary.allCases, id: \.self) { type in
                            Text(type.title)
                        }
                    }

                    if salary.title == Salary.pieceRate().title {
                        Stepper(
                            "Cтавка \(Int(salaryRate * 100)) %",
                            value: $salaryRate,
                            in: 0.2...0.6,
                            step: 0.1
                        )
                        .onChange(of: salaryRate) { _, newValue in
                            salary = .pieceRate(rate: newValue)
                        }
                    }
                } header: {
                    Text("Заработная плата")
                }

                if user.accessLevel == .boss {
                    Section {
                        Picker("Уровень доступа", selection: $userLevel) {
                            ForEach(UserAccessLevel.selectableCases) { level in
                                Text(level.title)
                            }
                        }
                    } header: {
                        Text("Пользователь")
                    }
                }

                Section {
                    TextEditor(text: $infoText)
                        .lineSpacing(6)
                } header: {
                    Text("Информация о специалисте")
                }
            }
            .sheet(isPresented: $addBasicService) {
                NavigationStack {
                    PricelistView(filterText: searchText, selectedPricelistItem: $basicService, isSearching: $isSearching)
                        .listStyle(.plain)
                        .searchable(
                            text: $searchText,
                            isPresented: $isSearching,
                            placement: .navigationBarDrawer(displayMode: .always)
                        )
                        .sheetToolbar(title: "Выберите услугу")
                        .onChange(of: basicService) {
                            addBasicService = false
                        }
                }
            }
            .sheetToolbar(
                title: "Новый специалист",
                confirmationDisabled: emptyNameText || invalidPhoneNumber
            ) {
                let doctor = Doctor(
                    secondName: secondNameText.trimmingCharacters(in: .whitespaces),
                    firstName: firstNameText.trimmingCharacters(in: .whitespaces),
                    patronymicName: patronymicNameText.trimmingCharacters(in: .whitespaces),
                    phoneNumber: phoneNumberText,
                    birthDate: birthDate,
                    department: department,
                    basicService: basicService?.short,
                    serviceDuration: serviceDuration,
                    defaultCabinet: defaultCabinet,
                    salary: salary,
                    info: infoText,
                    image: viewModel.imageData,
                    accessLevel: userLevel
                )
                modelContext.insert(doctor)
            }
        }
    }
}

#Preview {
    CreateDoctorView()
}

// MARK: - Calculations

private extension CreateDoctorView {
    var emptyNameText: Bool {
        secondNameText.isEmpty || firstNameText.isEmpty || patronymicNameText.isEmpty
    }

    var invalidPhoneNumber: Bool {
        phoneNumberText.count != 18 || phoneNumberText.isEmpty
    }
}
