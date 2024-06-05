//
//  PatientCardScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import SwiftUI

struct PatientCardScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var coordinator: Coordinator

    @Bindable var patient: Patient

    // MARK: - State

    @State private var currentDetail: DetailScreen = .passport

    // MARK: -

    var body: some View {
        SideBySideScreen(sidebarTitle: "Карта пациента", detailTitle: currentDetail.title) {
            Section {
                nameButton(\.secondName)
                nameButton(\.firstName)
                nameButton(\.patronymicName)
            } header: {
                Text("Имя")
            }

            Button(patient.phoneNumber) {
                currentDetail = .phoneNumber
            }
            .tint(.primary)

            Section {
                Button {
                    currentDetail = .passport
                } label: {
                    Label("Паспортные данные", systemImage: "person.crop.square.filled.and.at.rectangle")
                        .tint(.primary)
                }
            }

            Section {
                Button {
                    currentDetail = .visits
                } label: {
                    Label("Визиты", systemImage: "figure.walk.arrival")
                        .tint(.primary)
                }
            }

            Section {
                Button {
                    currentDetail = .transactions
                } label: {
                    LabeledContent {
                        CurrencyText(patient.balance)
                    } label: {
                        Label("Баланс", systemImage: "briefcase")
                            .tint(.primary)
                    }
                }
            }

            Section {
                Button {
                    currentDetail = .treatmentPlan
                } label: {
                    if let treatmentPlan = patient.currentTreatmentPlan {
                        if treatmentPlan.kind.isPregnancyAI {
                            Text(treatmentPlan.kind.rawValue)
                                .tint(.primary)
                                .colorInvert()
                        } else {
                            LabeledContent {
                                Text("до")
                                DateText(treatmentPlan.expirationDate, format: .date)
                            } label: {
                                Text(treatmentPlan.kind.rawValue)
                            }
                            .tint(.primary)
                            .colorInvert()
                        }
                    } else {
                        Text("Активировать")
                    }
                }
                .listRowBackground(patient.currentTreatmentPlan != nil ? Color.appBlack : Color(.secondarySystemGroupedBackground))
            } header: {
                Text("Лечебный план")
            }

            if user.accessLevel == .boss, patient.balance == 0, patient.currentTreatmentPlan == nil {
                Section {
                    Button("Удалить", role: .destructive) {
                        dismiss()
                        modelContext.delete(patient)
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
    NavigationStack {
        PatientCardScreen(patient: ExampleData.patient)
    }
    .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension PatientCardScreen {
    enum DetailScreen {
        case name
        case phoneNumber
        case passport
        case treatmentPlan
        case visits
        case transactions

        var title: String {
            switch self {
            case .name:
                return "ФИО"
            case .phoneNumber:
                return "Номер телефона"
            case .passport:
                return "Паспортные данные"
            case .treatmentPlan:
                return "Активировать лечебный план"
            case .visits:
                return "Последние визиты"
            case .transactions:
                return "Транзакции"
            }
        }
    }

    @ViewBuilder var detail: some View {
        switch currentDetail {
        case .name:
            NameEditView(
                person:
                    Binding(
                        get: { patient },
                        set: {
                            patient.secondName = $0.secondName
                            patient.firstName = $0.firstName
                            patient.patronymicName = $0.patronymicName
                        }
                    )
            )
        case .phoneNumber:
            PhoneNumberEditView(
                person: Binding(get: { patient }, set: { patient.phoneNumber = $0.phoneNumber })
            )
        case .passport:
            PassportDetailView(patient: patient)
        case .treatmentPlan:
            TreatmentPlanView(patient: patient)
        case .visits:
            VisitsDetailView(patient: patient)
        case .transactions:
            PatientTransactionsView(patient: patient)
        }
    }

    func nameButton(_ keyPath: KeyPath<Person, String>) -> some View {
        Button(patient[keyPath: keyPath]) {
            currentDetail = .name
        }
        .tint(.primary)
    }
}
