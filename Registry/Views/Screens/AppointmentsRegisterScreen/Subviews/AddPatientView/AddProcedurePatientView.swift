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
    @FocusState private var isFocused: Bool

    // MARK: -

    init(schedule: DoctorSchedule) {
        self.schedule = schedule
        _time = State(
            initialValue: min(
                max(
                    WorkingHours(for: schedule.starting).start,
                    Calendar.current.date(bySetting: .minute, value: 0, of: .now) ?? .now
                ),
                WorkingHours(for: schedule.starting).end.addingTimeInterval(-(schedule.doctor?.serviceDuration ?? 600))
            )
        )
        _duration = State(initialValue: schedule.doctor?.serviceDuration ?? 0)

        UIDatePicker.appearance().minuteInterval = 5
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DateText(time, format: .weekDay)
                    DatePicker(
                        "Время",
                        selection: $time,
                        in: datePickerRange,
                        displayedComponents: .hourAndMinute
                    )
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
                        LabeledContent {
                            Text("до")
                            DateText(treatmentPlan.expirationDate, format: .date)
                        } label: {
                            Text(treatmentPlan.kind.rawValue)
                        }
                        .tint(.primary)
                        .colorInvert()
                        .listRowBackground(Color(.appBlack))
                    }
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
            .sheetToolbar("Регистрация пациента", disabled: emptyTextDetection || !validPhoneNumber) {
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
    var datePickerRange: ClosedRange<Date> {
        let workingHours = WorkingHours(for: schedule.starting)
        let minDate = workingHours.start
        let maxDate = workingHours.end.addingTimeInterval(-(schedule.doctor?.serviceDuration ?? 600))

        return minDate...maxDate
    }

    var durationBounds: ClosedRange<TimeInterval> {
        guard let doctor = schedule.doctor else { return 300...1800 }

        let minDuration = doctor.serviceDuration
        let maxDuration = schedule.maxServiceDuration(forAppointmentTime: time)

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
}
