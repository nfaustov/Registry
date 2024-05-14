//
//  NoteView.swift
//  Registry
//
//  Created by Николай Фаустов on 14.05.2024.
//

import SwiftUI

struct NoteView: View {
    // MARK: - Dependencies

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let appointment: PatientAppointment

    // MARK: - State

    @State private var navigationTitle = "Новая заметка"
    @State private var noteText = ""
    @State private var charactersCount: Int = 0

    // MARK: -

    init(for appointment: PatientAppointment) {
        self.appointment = appointment

        if let note = appointment.note {
            _navigationTitle = State(initialValue: "Заметка")
            _noteText = State(initialValue: note.text)
            _charactersCount = State(initialValue: note.text.count)
        }
    }
    var body: some View {
        NavigationStack {
            Form {
                Section("Прием пациента") {
                    LabeledContent(
                        appointment.patient?.fullName ?? "",
                        value: DateFormat.dateTime.string(from: appointment.scheduledTime)
                    )
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

                if let note = appointment.note {
                    Section {
                        Button("Удалить", role: .destructive) {
                            modelContext.delete(note)
                            dismiss()
                        }
                    }
                }
            }
            .sheetToolbar(navigationTitle, disabled: noteText.isEmpty) {
                if let note = appointment.note {
                    note.updateText(noteText)
                } else {
                    let note = Note(text: noteText, createdBy: user)
                    appointment.note = note
                }

                dismiss()
            }
        }
    }
}

#Preview {
    NoteView(for: ExampleData.appointment)
}
