//
//  AddProcedurePatientView.swift
//  Registry
//
//  Created by Николай Фаустов on 03.04.2024.
//

import SwiftUI
import SwiftData

struct AddProcedurePatientView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @StateObject private var messageController = MessageController()

    @Query private var patients: [Patient]

    @Bindable var schedule: DoctorSchedule

    // MARK: - State

    @State private var time: Date = .now
    @State private var findPatient: Bool = false
    @State private var selectedPatient: Patient?
    @State private var secondNameText = ""
    @State private var firstNameText = ""
    @State private var patronymicNameText = ""
    @State private var phoneNumberText = ""
    @State private var duration: TimeInterval

    // MARK: -

    init(schedule: DoctorSchedule) {
        self.schedule = schedule

        if Calendar.current.isDateInToday(schedule.starting) {
            _time = State(initialValue: .now)
        } else {
            _time = State(initialValue: Calendar.current.date(bySetting: .hour, value: 8, of: schedule.starting) ?? schedule.starting)
        }

        _duration = State(initialValue: schedule.doctor?.serviceDuration ?? 0)

        UIDatePicker.appearance().minuteInterval = 5
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DateText(time, format: .weekDay)
                    DatePicker("Время", selection: $time, displayedComponents: .hourAndMinute)
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
                            .onChange(of: phoneNumberText) {
                                if phoneNumberText.count == 18, let patient = patients.first(where: { $0.phoneNumber == phoneNumberText }) {
                                    selectedPatient = patient
                                }
                            }
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
            }
            .listStyle(.insetGrouped)
            .sheetToolbar(
                title: "Регистрация пациента",
                confirmationDisabled: emptyTextDetection || !validPhoneNumber
            ) {
                if let selectedPatient {
                    schedule.createPatientAppointment(date: time) { appointment in
                        appointment.registerPatient(selectedPatient, duration: duration, registrar: user.asAnyUser)
                    }
                } else {
                    let patient = Patient(
                        secondName: secondNameText.trimmingCharacters(in: .whitespaces),
                        firstName: firstNameText.trimmingCharacters(in: .whitespaces),
                        patronymicName: patronymicNameText.trimmingCharacters(in: .whitespaces),
                        phoneNumber: phoneNumberText
                    )

                    schedule.createPatientAppointment(date: time) { appointment in
                        appointment.registerPatient(patient, duration: duration, registrar: user.asAnyUser)
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
    AddProcedurePatientView(schedule: ExampleData.doctorSchedule)
}

// MARK: - Calculations

private extension AddProcedurePatientView {
    var durationBounds: ClosedRange<TimeInterval> {
        guard let doctor = schedule.doctor else { return 300...1800 }

        let minDuration = doctor.serviceDuration

        return minDuration...3600
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
}