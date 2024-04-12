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

            Button {
                currentDetail = .visits
            } label: {
                Label("Визиты", systemImage: "figure.walk.arrival")
                    .tint(.primary)
            }

            if let treatmentPlan = patient.treatmentPlan {
                Section {
                    HStack {
                        Text(treatmentPlan.kind.rawValue)
                        Spacer()
                        Group {
                            Text("Истекает")
                            DateText(treatmentPlan.expirationDate, format: .date)
                        }
                        .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Лечебный план")
                }
            }

            Section("Баланс") {
                LabeledContent("\(Int(patient.balance)) ₽") {
                    Button("Пополнить") {
                        coordinator.present(
                            .updateBalance(
                                for: Binding(get: { patient }, set: { value in patient.balance = value.balance }),
                                kind: .refill
                            )
                        )
                    }
                }
            }

            if user.accessLevel == .boss {
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
        case visits
        case passport

        var title: String {
            switch self {
            case .name:
                return "ФИО"
            case .phoneNumber:
                return "Номер телефона"
            case .visits:
                return "Последние визиты"
            case .passport:
                return "Паспортные данные"
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
        case .visits:
            VisitsDetailView(patient: patient)
        case .passport:
            PassportDetailView(patient: patient)
        }
    }

    func nameButton(_ keyPath: KeyPath<Person, String>) -> some View {
        Button(patient[keyPath: keyPath]) {
            currentDetail = .name
        }
        .tint(.primary)
    }
}
