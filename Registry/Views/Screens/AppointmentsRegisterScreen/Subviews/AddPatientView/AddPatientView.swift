//
//  AddPatientView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.02.2024.
//

import SwiftUI
import SwiftData

struct AddPatientView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @StateObject var messageController = MessageController()

    @Query private var patients: [Patient]

    @Bindable var appointment: PatientAppointment

    // MARK: - State

    @State private var findPatient: Bool = false
    @State private var selectedPatient: Patient?
    @State private var secondNameText = ""
    @State private var firstNameText = ""
    @State private var patronymicNameText = ""
    @State private var phoneNumberText = ""
    @State private var duration: TimeInterval
    @State private var selection: Visit.ID?
    @State private var smsNotification: Bool = true

    // MARK: -

    init(appointment: PatientAppointment) {
        self.appointment = appointment
        _duration = State(initialValue: appointment.duration)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent {
                        DateText(appointment.scheduledTime, format: .time)
                    } label: {
                        DateText(appointment.scheduledTime, format: .weekDay)
                    }
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
                            .onSubmit {
                                if let patient = patients.first(where: { $0.phoneNumber == phoneNumberText }) {
                                    selectedPatient = patient
                                }
                            }
                    }

                    Toggle("СМС оповещение", isOn: $smsNotification)
                } header: {
                    Text("Номер телефона")
                }

                Section {
                    if durationBounds.lowerBound < durationBounds.upperBound {
                        Stepper(
                            value: $duration.animation(),
                            in: durationBounds,
                            step: durationBounds.lowerBound
                        ) {
                            DurationLabel(duration, systemImage: "clock")
                                .contentTransition(.numericText())
                        }
                    } else {
                        DurationLabel(duration, systemImage: "clock")
                    }
                } header: {
                    Text("Длительность")
                }

                if let selectedPatient, !selectedPatient.currentVisits(for: appointment.scheduledTime).isEmpty {
                    Section {
                        ForEach(selectedPatient.currentVisits(for: appointment.scheduledTime)) { visit in
                            LabeledContent {
                                Image(systemName: selection == visit.id ? "personalhotspot.circle.fill": "personalhotspot.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(selection == visit.id ? .blue : .secondary)
                                    .frame(width: 24, height: 24)
                                    .padding(.horizontal)
                            } label: {
                                VStack {
                                    ForEach(selectedPatient.mergedAppointments(forVisitID: visit.id).sorted(by: { $0.scheduledTime < $1.scheduledTime })) { visitAppointment in
                                        if let doctor = visitAppointment.schedule?.doctor {
                                            LabeledContent {
                                                DateText(visitAppointment.scheduledTime, format: .time)
                                                    .padding(.horizontal)
                                            } label: {
                                                Text(doctor.initials)
                                                    .foregroundStyle(.primary)
                                            }
                                        }
                                    }
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    if selection == visit.id {
                                        selection = nil
                                    } else {
                                        selection = visit.id
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Текущие визиты на \(DateFormat.weekDay.string(from: appointment.scheduledTime))")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .sheetToolbar(
                title: "Регистрация пациента",
                confirmationDisabled: emptyTextDetection || !validPhoneNumber
            ) {
                replaceAppointmentsIfNeeded()

                if let selectedPatient {
                    if let selection {
                        appointment.registerPatient(selectedPatient, duration: duration, mergedVisitID: selection)
                        selectedPatient.specifyVisitDate(selection)
                    } else {
                        appointment.registerPatient(selectedPatient, duration: duration, registrar: user.asAnyUser)
                    }
                } else {
                    let patient = Patient(
                        secondName: secondNameText.trimmingCharacters(in: .whitespaces),
                        firstName: firstNameText.trimmingCharacters(in: .whitespaces),
                        patronymicName: patronymicNameText.trimmingCharacters(in: .whitespaces),
                        phoneNumber: phoneNumberText
                    )

                    appointment.registerPatient(patient, duration: duration, registrar: user.asAnyUser)
                }

                if smsNotification {
                    Task {
                        await messageController.send(.appointmentConfirmation(appointment))

                        if !messageController.showErrorMessage {
                            appointment.status = .notified
                        }
                    }
                }
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
        let deletingAppointments = appointment.schedule?.patientAppointments?
            .sorted(by: { $0.scheduledTime < $1.scheduledTime })
            .filter { deletingAppointmentsInterval.contains($0.scheduledTime) }
            .dropFirst() ?? []

        guard deletingAppointments.compactMap({ $0.patient }).isEmpty else { return }

        for appointment in deletingAppointments {
            modelContext.delete(appointment)
        }
    }
}
