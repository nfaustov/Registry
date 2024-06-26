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

    @StateObject private var messageController = MessageController()

    @Query private var patients: [Patient]
    @Query private var doctors: [Doctor]

    @Bindable var appointment: PatientAppointment

    // MARK: - State

    @State private var findPatient: Bool = false
    @State private var selectedPatient: Patient?
    @State private var secondNameText = ""
    @State private var firstNameText = ""
    @State private var patronymicNameText = ""
    @State private var phoneNumberText = ""
    @State private var duration: TimeInterval
    @State private var selection: Check?
    @State private var smsNotification: Bool = false
    @State private var registrar: AnyUser = AnonymousUser().asAnyUser
    @FocusState private var isFocused: Bool

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
                        Text(selectedPatient.fullName)
                    } else {
                        TextField("Фамилия", text: $secondNameText)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                        TextField("Имя", text: $firstNameText)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                        TextField("Отчество", text: $patronymicNameText)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                    }
                } header: {
                    Text("Ф.И.О.")
                }

                if let selectedPatient, let treatmentPlan = selectedPatient.currentTreatmentPlan {
                    Section("Лечебный план") {
                        if treatmentPlan.kind.isPregnancyAI {
                            Text(treatmentPlan.kind.rawValue)
                                .colorInvert()
                        } else {
                            LabeledContent(treatmentPlan.kind.rawValue) {
                                Text("до")
                                DateText(treatmentPlan.expirationDate, format: .date)
                            }
                            .colorInvert()
                        }
                    }
                    .listRowBackground(Color(.appBlack))
                }

                Section {
                    if let selectedPatient {
                        Text(selectedPatient.phoneNumber)
                    } else {
                        PhoneNumberTextField(text: $phoneNumberText, focus: { isFocused = false })
                            .onChange(of: phoneNumberText) {
                                if phoneNumberText.count == 18, let patient = patients.first(where: { $0.phoneNumber == phoneNumberText }) {
                                    selectedPatient = patient
                                }
                                if disableNotification {
                                    smsNotification = false
                                }
                            }
                    }

                    if let doctor = appointment.schedule?.doctor, doctor.department != .procedure {
                        Toggle("СМС оповещение", isOn: $smsNotification)
                            .disabled(disableNotification)
                    }
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

                if let selectedPatient, !selectedPatient.checks(for: appointment.scheduledTime).isEmpty {
                    Section {
                        ForEach(selectedPatient.checks(for: appointment.scheduledTime)) { check in
                            LabeledContent {
                                Image(systemName: selection == check ? "personalhotspot.circle.fill": "personalhotspot.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(selection == check ? .blue : .secondary)
                                    .frame(width: 24, height: 24)
                                    .padding(.horizontal)
                            } label: {
                                VStack {
                                    ForEach(selectedPatient.mergedAppointments(forCheckID: check.id).sorted(by: { $0.scheduledTime < $1.scheduledTime })) { checkAppointment in
                                        if let doctor = checkAppointment.schedule?.doctor {
                                            LabeledContent {
                                                DateText(checkAppointment.scheduledTime, format: .time)
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
                                    if selection == check {
                                        selection = nil
                                    } else {
                                        selection = check
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Текущие визиты на \(DateFormat.weekDay.string(from: appointment.scheduledTime))")
                    }
                }

                Section("Регистратор") {
                    Picker(registrar.initials, selection: $registrar) {
                        let registrars = doctors
                            .filter({ $0.accessLevel == .registrar })
                            .map { $0.asAnyUser }
                        ForEach(registrars, id: \.self) { registrar in
                            Text(registrar.initials)
                                .tag(registrar.id)
                        }
                    }
                }
                .onAppear {
                    registrar = user.asAnyUser
                }
            }
            .listStyle(.insetGrouped)
            .sheetToolbar(
                "Регистрация пациента",
                disabled: emptyTextDetection || !validPhoneNumber
            ) {
                replaceAppointmentsIfNeeded()

                if let selectedPatient {
                    appointment.registerPatient(
                        selectedPatient,
                        duration: duration,
                        registrar: registrar,
                        mergedCheck: selection
                    )
                } else {
                    let patient = Patient(
                        secondName: secondNameText.trimmingCharacters(in: .whitespaces),
                        firstName: firstNameText.trimmingCharacters(in: .whitespaces),
                        patronymicName: patronymicNameText.trimmingCharacters(in: .whitespaces),
                        phoneNumber: phoneNumberText
                    )

                    appointment.registerPatient(patient, duration: duration, registrar: registrar)
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
            .alert(
                "Не удалось отправить SMS",
                isPresented: $messageController.showErrorMessage,
                presenting: messageController.errorMessage
            ) { _ in
                Button("Ok") { messageController.showErrorMessage = false }
            } message: { Text($0) }
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
        let maxDuration = selectedSchedule.maxServiceDuration(forAppointmentTime: appointment.scheduledTime)

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
            return phoneNumberText.count == 18 || phoneNumberText == "+7"
        }
    }

    var disableNotification: Bool {
        if let selectedPatient {
            return selectedPatient.phoneNumber.count != 18
        } else {
            return phoneNumberText.count != 18
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
