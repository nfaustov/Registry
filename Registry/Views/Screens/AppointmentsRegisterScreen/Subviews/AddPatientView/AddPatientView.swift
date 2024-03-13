//
//  AddPatientView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.02.2024.
//

import SwiftUI

struct AddPatientView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Bindable var appointment: PatientAppointment

    // MARK: - State

    @State private var findPatient: Bool = false
    @State private var selectedPatient: Patient?
    @State private var secondNameText = ""
    @State private var firstNameText = ""
    @State private var patronymicNameText = ""
    @State private var phoneNumberText = ""
    @State private var duration: TimeInterval

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment
        _duration = State(initialValue: appointment.duration)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DateText(appointment.scheduledTime, format: .weekDay)
                    DateText(appointment.scheduledTime, format: .time)
                } header: {
                    Text("Дата / Время")
                }

                Section {
                    Button {
                        findPatient = true
                    } label: {
                        Label("Поиск", systemImage: "person.fill.viewfinder")
                    }
                }

                Section {
                    if let selectedPatient {
                        Text(selectedPatient.secondName)
                        Text(selectedPatient.firstName)
                        Text(selectedPatient.patronymicName)
                    } else {
                        TextField("Фамилия", text: $secondNameText)
                            .autocorrectionDisabled()
                        TextField("Имя", text: $firstNameText)
                            .autocorrectionDisabled()
                        TextField("Отчество", text: $patronymicNameText)
                            .autocorrectionDisabled()
                    }
                } header: {
                    Text("Ф.И.О.")
                }

                Section {
                    if let selectedPatient {
                        Text(selectedPatient.phoneNumber)
                    } else {
                        PhoneNumberTextField(text: $phoneNumberText)
                    }
                } header: {
                    Text("Номер телефона")
                }

                Section {
                    DurationLabel(duration, systemImage: "clock")
                    if durationBounds.lowerBound < durationBounds.upperBound {
                        Slider(
                            value: $duration,
                            in: durationBounds,
                            step: durationBounds.lowerBound
                        )
                    }
                } header: {
                    Text("Длительность")
                }

            }
            .listStyle(.insetGrouped)
            .sheetToolbar(
                title: "Регистрация пациента",
                confirmationDisabled: emptyTextDetection || !validPhoneNumber
            ) {
                replaceAppointmentsIfNeeded()

                let visit = Visit(visitDate: appointment.scheduledTime)

                if let selectedPatient {
                    appointment.patient = selectedPatient
                } else {
                    let patient = Patient(
                        secondName: secondNameText.trimmingCharacters(in: .whitespaces),
                        firstName: firstNameText.trimmingCharacters(in: .whitespaces),
                        patronymicName: patronymicNameText.trimmingCharacters(in: .whitespaces),
                        phoneNumber: phoneNumberText
                    )
                    appointment.patient = patient
                }

                appointment.duration = duration
                appointment.status = .registered
                appointment.patient?.visits.append(visit)
            }
            .sheet(isPresented: $findPatient) {
                PatientsList(selectedPatient: $selectedPatient)
            }
        }
    }
}

#Preview {
    AddPatientView(appointment: ExampleData.appointment)
}

// MARK: - Calculations

private extension AddPatientView {
    var durationBounds: ClosedRange<TimeInterval> {
        guard let selectedSchedule = appointment.schedule,
              let doctor = selectedSchedule.doctor else { return 300...1800 }

        let minDuration = doctor.serviceDuration
        let maxDuration = selectedSchedule.maxServiceDuration(for: appointment)

        return minDuration...maxDuration
    }

    var emptyTextDetection: Bool {
        if selectedPatient != nil {
            return false
        } else {
            return secondNameText.isEmpty || firstNameText.isEmpty || patronymicNameText.isEmpty
        }
    }

    var validPhoneNumber: Bool {
        if selectedPatient != nil {
            return true
        } else {
            return phoneNumberText.count == 18
        }
    }

    func replaceAppointmentsIfNeeded() {
        let deletingAppointmentsInterval = appointment.scheduledTime..<appointment.scheduledTime.addingTimeInterval(duration)
        let deletingAppointments = appointment.schedule?.patientAppointments
            .filter { $0.status != .cancelled }
            .sorted(by: { $0.scheduledTime < $1.scheduledTime })
            .filter { deletingAppointmentsInterval.contains($0.scheduledTime) }
            .dropFirst() ?? []

        guard deletingAppointments.compactMap({ $0.patient }).isEmpty else { return }

        for appointment in deletingAppointments {
            modelContext.delete(appointment)
        }
    }
}
