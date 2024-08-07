//
//  AppointmentView.swift
//  Registry
//
//  Created by Николай Фаустов on 23.02.2024.
//

import SwiftUI

struct AppointmentView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    @Bindable var appointment: PatientAppointment

    // MARK: - State

    @State private var showNote: Bool = false
    @State private var showBalance: Bool = false

    // MARK: -

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .frame(width: 8)
                .foregroundStyle(style)

            Text(timePoint(appointment.scheduledTime))
                .foregroundColor(appointment.status == .completed ? .secondary : .primary)
                .bold()
                .frame(width: 50)
                .padding(8)

            if let patient = appointment.patient {
                VStack(alignment: .leading) {
                    HStack {
                        Text(patient.fullName)

                        if patient.currentTreatmentPlan != nil {
                            Image(systemName: "cross.case.circle")
                                .foregroundStyle(.orange)
                        }
                    }

                    Text(patient.phoneNumber)
                }
                .foregroundColor(appointment.status == .completed ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)

                if appointment.status == .completed {
                    Button {
                        coordinator.present(.completedAppointment(appointment: appointment))
                    } label: {
                        HStack {
                            Text(appointment.status?.rawValue ?? "")
                                .foregroundColor(.secondary)
                            Image(systemName: "info.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20)
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    if patient.balance != 0 {
                        Image(systemName: "briefcase.fill")
                            .font(.headline)
                            .foregroundStyle(showBalance ? .gray.opacity(0.4) : patient.balance > 0 ? .green : .pink)
                            .padding(8)
                            .background(patient.balance > 0 ? .green.opacity(0.1) : .pink.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 8, style: .continuous))
                            .padding(.horizontal, 4)
                            .onTapGesture {
                                showBalance = true
                            }
                            .popover(isPresented: $showBalance) {
                                LabeledCurrency("Баланс", value: patient.balance)
                                    .padding()
                            }
                    }

                    if let note = appointment.note {
                        Image(systemName: "note.text")
                            .font(.headline)
                            .foregroundStyle(showNote ? .gray.opacity(0.4) : .indigo)
                            .padding(8)
                            .background(.indigo.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 8, style: .continuous))
                            .padding(.horizontal, 4)
                            .onTapGesture {
                                showNote = true
                            }
                            .popover(isPresented: $showNote) {
                                Text(note.text)
                                    .padding()
                            }
                    }

                    if appointment.status == .notified {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark.circle")
                            Text("SMS")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.teal)
                        .padding(4)
                    }

                    Picker("", selection: Binding(get: { appointment.status ?? .registered }, set: { appointment.status = $0 })) {
                        ForEach(PatientAppointment.Status.selectableCases) { status in
                            Text(status.rawValue)
                        }
                    }
                    .tint(.secondary)
                    .frame(width: 212)
                }
            } else {
                Spacer()

                Button {
                    coordinator.present(.addPatient(for: appointment))
                } label: {
                    Image(systemName: "person.badge.plus")
                        .padding(6)
                }
                .buttonStyle(.bordered)
                .opacity(appointment.scheduledTime > Calendar.current.startOfDay(for: .now) ? 1 : 0)
            }
        }
    }
}

#Preview {
    AppointmentView(appointment: ExampleData.appointment)
        .environmentObject(Coordinator())
}

// MARK: - Calculations

private extension AppointmentView {
    func timePoint(_ time: Date) -> String {
        DateFormatter.shared.dateFormat = "H:mm"
        return DateFormatter.shared.string(from: time)
    }

    var style: Color {
        switch appointment.status {
        case .came:
                .red
        case .inProgress:
                .purple
        default:
            Color(.systemFill)
        }
    }
}
