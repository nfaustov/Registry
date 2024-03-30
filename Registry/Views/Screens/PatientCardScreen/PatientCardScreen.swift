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

    @Bindable var patient: Patient

    // MARK: - State

    @State private var currentDetail: DetailScreen = .passport

    // MARK: -

    var body: some View {
        SideBySideScreen(sidebarTitle: "Карта пациента", detailTitle: currentDetail.title) {
            Section {
                Text(patient.secondName)
                Text(patient.firstName)
                Text(patient.patronymicName)
            } header: {
                Text("Имя")
            }

            Section {
                Text(patient.phoneNumber)
            } header: {
                Text("Номер телефона")
            }

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

            if patient.balance != 0 {
                Section {
                    HStack {
                        Text("Баланс:")
                        Spacer()
                        Text("\(Int(patient.balance)) ₽")
                    }
                }
            }
        } detail: {
            currentDetail.detail(patient)
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
        case visits
        case passport

        var title: String {
            switch self {
            case .visits:
                return "Последние визиты"
            case .passport:
                return "Паспортные данные"
            }
        }

        @ViewBuilder func detail(_ patient: Patient) -> some View {
            switch self {
            case .visits:
                VisitsDetailView(visits: patient.visits)
            case .passport:
                PassportDetailView(patient: patient)
            }
        }
    }
}
