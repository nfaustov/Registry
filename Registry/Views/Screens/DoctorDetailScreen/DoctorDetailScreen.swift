//
//  DoctorDetailScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI

struct DoctorDetailScreen: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user

    @Bindable var doctor: Doctor

    // MARK: -

    @State private var currentDetail: DoctorDetailContext = .phoneNumber

    // MARK: -

    var body: some View {
        SideBySideScreen(sidebarTitle: "Врач", detailTitle: currentDetail.title) {
            Section {
                
            }

            Section {
                nameButton(\.secondName)
                nameButton(\.firstName)
                nameButton(\.patronymicName)
            } header: {
                Text("Имя")
            }

            Button(doctor.phoneNumber) {
                currentDetail = .phoneNumber
            }
            .tint(.primary)
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
        case name
        case phoneNumber

        var title: String {
            switch self {
            case .name:
                return "ФИО"
            case .phoneNumber:
                return "Номер телефона"
            }
        }
    }

    @ViewBuilder var detail: some View {
        switch currentDetail {
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
        }
    }

    func nameButton(_ keyPath: KeyPath<Person, String>) -> some View {
        Button(doctor[keyPath: keyPath]) {
            currentDetail = .name
        }
        .tint(.primary)
    }
}
