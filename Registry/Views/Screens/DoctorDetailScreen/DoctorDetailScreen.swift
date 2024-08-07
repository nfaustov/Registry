//
//  DoctorDetailScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI
import PhotosUI

struct DoctorDetailScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    @EnvironmentObject private var coordinator: Coordinator

    @StateObject private var viewModel = PhotosPickerViewModel()

    @Bindable var doctor: Doctor

    // MARK: - State

    @State private var currentDetail: DoctorDetailContext = .doctorSettings
    @State private var showPricelist: Bool = false
    @State private var isSearchingPricelistItem: Bool = false
    @State private var searchText: String = ""

    // MARK: -

    var body: some View {
        SideBySideScreen(sidebarTitle: "Врач", detailTitle: currentDetail.title) {
            if doctor.image != nil {
                PersonImageView(person: doctor)
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
                    .onTapGesture {
                        currentDetail = .photo
                    }
            } else {
                Button {
                    currentDetail = .photo
                } label: {
                    Label("Выбрать фото", systemImage: "photo.badge.plus")
                        .tint(.primary)
                }
            }

            Section {
                nameButton(\.secondName)
                nameButton(\.firstName)
                nameButton(\.patronymicName)
            }

            Section {
                Button(doctor.phoneNumber) {
                    currentDetail = .phoneNumber
                }
                .tint(.primary)
            }

            Section("Дата рождения") {
                Button(DateFormat.birthDate.string(from: doctor.birthDate)) {
                    currentDetail = .birthDate
                }
                .tint(.primary)
            }

            Section {
                Button {
                    currentDetail = .doctorInfo
                } label: {
                    Label("Информация", systemImage: "info.square")
                        .tint(.primary)
                }

                Button {
                    currentDetail = .doctorSettings
                } label: {
                    Label("Настройки расписания", systemImage: "slider.horizontal.2.square")
                        .tint(.primary)
                }

                Button {
                    currentDetail = .vacationSchedule
                } label: {
                    Label("Отпуск", systemImage: "person.crop.circle.badge.moon")
                        .tint(.primary)
                }

                Button {
                    currentDetail = .transactions
                } label: {
                    LabeledContent {
                        CurrencyText(doctor.balance)
                    } label: {
                        Label("Баланс", systemImage: "briefcase")
                            .tint(.primary)
                    }
                }
            }

            Section {
                if let patient = doctor.asPatient {
                    Button("Карта пациента") {
                        coordinator.push(.patientCard(patient))
                    }
                } else {
                    Button("Добавить как пациента") {
                        let treatmentPlan = TreatmentPlan(kind: .basic)
                        let patient = Patient(
                            secondName: doctor.secondName,
                            firstName: doctor.firstName,
                            patronymicName: doctor.patronymicName,
                            phoneNumber: doctor.phoneNumber,
                            balance: doctor.balance,
                            passport: Patient.PassportData(birthday: doctor.birthDate),
                            treatmentPlans: [treatmentPlan]
                        )
                        doctor.asPatient = patient
                        patient.passport.birthday = doctor.birthDate

                        coordinator.push(.patientCard(patient))
                    }
                }
            }
        } detail: {
            detail
                .disabled(user.accessLevel < .registrar)
        }
    }
}

#Preview {
    DoctorDetailScreen(doctor: ExampleData.doctor)
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension DoctorDetailScreen {
    enum DoctorDetailContext {
        case photo
        case name
        case phoneNumber
        case birthDate
        case transactions
        case doctorSettings
        case vacationSchedule
        case doctorInfo

        var title: String {
            switch self {
            case .photo:
                return "Фотография"
            case .name:
                return "ФИО"
            case .phoneNumber:
                return "Номер телефона"
            case .birthDate:
                return "День рождения"
            case .transactions:
                return "Транзакции"
            case .doctorSettings:
                return "Настройки расписания"
            case .vacationSchedule:
                return "График отпусков"
            case .doctorInfo:
                return "Информация о враче"
            }
        }
    }

    @ViewBuilder var detail: some View {
        switch currentDetail {
        case .photo:
            Form {
                Section {
                    if let image = viewModel.selectedImage {
                        doctorImage(image)
                    } else if let imageData = doctor.image, let image = UIImage(data: imageData) {
                        doctorImage(image)
                    }
                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                        Text("Выберите фото")
                    }
                }

                Button("Сохранить") {
                    doctor.image = viewModel.imageData
                }
                .disabled(viewModel.imageData == doctor.image || viewModel.imageData == nil)
            }
        case .name:
            NameEditView(
                person:
                    Binding(
                        get: { doctor },
                        set: { 
                            doctor.secondName = $0.secondName
                            doctor.firstName = $0.firstName
                            doctor.patronymicName = $0.patronymicName
                        }
                    )
            )
        case .phoneNumber:
            PhoneNumberEditView(
                person: Binding(get: { doctor }, set: { doctor.phoneNumber = $0.phoneNumber })
            )
        case .birthDate:
            Form {
                DatePicker(
                    "Дата рождения",
                    selection: $doctor.birthDate,
                    in: Date.distantPast...,
                    displayedComponents: .date
                )
            }
        case .transactions:
            DoctorTransactionsView(doctor: doctor)
        case .doctorSettings:
            DoctorSettingsView(doctor: doctor)
        case .vacationSchedule:
            DoctorVacationView(doctor: doctor)
        case .doctorInfo:
            Form {
                Section {
                    TextEditor(text: $doctor.info)
                        .lineSpacing(6)
                } header: {
                    Text("Информация о специалисте")
                }
            }
        }
    }

    func nameButton(_ keyPath: KeyPath<Person, String>) -> some View {
        Button(doctor[keyPath: keyPath]) {
            currentDetail = .name
        }
        .tint(.primary)
    }

    func doctorImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 200, height: 300)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
    }
}
