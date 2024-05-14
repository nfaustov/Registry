//
//  CreateNoteView.swift
//  Registry
//
//  Created by Николай Фаустов on 14.05.2024.
//

import SwiftUI

struct CreateNoteView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let appointment: PatientAppointment?
    let schedule: DoctorSchedule?

    // MARK: - State

    @State private var navigationTitle = "Новая заметка"
    @State private var noteText = ""
    @State private var charactersCount: Int = 0

    // MARK: -

    init(for appointment: PatientAppointment) {
        self.appointment = appointment
        schedule = nil

        if let note = appointment.note {
            _navigationTitle = State(initialValue: "Заметка")
            _noteText = State(initialValue: note.text)
            _charactersCount = State(initialValue: note.text.count)
        }
    }

    init(for schedule: DoctorSchedule) {
        self.schedule = schedule
        appointment = nil

        if let note = schedule.note {
            _navigationTitle = State(initialValue: "Заметка")
            _noteText = State(initialValue: note.text)
            _charactersCount = State(initialValue: note.text.count)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if let appointment {
                    Section("Прием пациента") {
                        LabeledContent(
                            appointment.patient?.fullName ?? "",
                            value: DateFormat.dateTime.string(from: appointment.scheduledTime)
                        )
                    }
                } else if let schedule {
                    Section("Расписание врача") {
                        LabeledContent(
                            schedule.doctor?.initials ?? "",
                            value: DateFormat.dateTime.string(from: schedule.starting)
                        )
                    }
                }

                Section {
                    TextEditor(text: $noteText)
                        .frame(height: 80)
                        .onChange(of: noteText) { oldValue, newValue in
                            charactersCount = newValue.count

                            if charactersCount > Note.charactersMax {
                                noteText = oldValue
                            }
                        }
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(charactersCount)/\(Note.charactersMax)")
                            .foregroundStyle(charactersCount == Note.charactersMax ? .red : .secondary)
                    }
                }

                if let note {
                    Section {
                        Button("Удалить", role: .destructive) {
                            withAnimation {
                                if let appointment {
                                    appointment.note = nil
                                } else if let schedule {
                                    schedule.note = nil
                                }
                            }

                            modelContext.delete(note)
                            dismiss()
                        }
                    }
                }
            }
            .sheetToolbar(navigationTitle, disabled: noteText.isEmpty || !hasChanges) {
                if let note {
                    note.updateText(noteText)
                } else {
                    if let appointment {
                        let patientInitials = appointment.patient?.initials ?? ""
                        let scheduledTime = DateFormat.dateTime.string(from: appointment.scheduledTime)
                        let title = "Прием пациента: \(patientInitials) \(scheduledTime)"
                        let note = Note(title: title, text: noteText, createdBy: user)
                        appointment.note = note
                    } else if let schedule {
                        let doctorInitials = schedule.doctor?.initials ?? ""
                        let scheduleStarting = DateFormat.dateTime.string(from: schedule.starting)
                        let title = "Врач: \(doctorInitials) \(scheduleStarting)"
                        let note = Note(title: title, text: noteText, createdBy: user)
                        schedule.note = note
                    }
                }

                dismiss()
            }
        }
    }
}

#Preview {
    CreateNoteView(for: ExampleData.appointment)
}

// MARK: - Calculations

private extension CreateNoteView {
    var note: Note? {
        if let appointment {
            return appointment.note
        } else if let schedule {
            return schedule.note
        } else { return nil }
    }

    var hasChanges: Bool {
        note?.text != noteText
    }
}
