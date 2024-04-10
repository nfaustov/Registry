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

    // MARK: -

    var body: some View {
        HStack {
            Circle()
                .frame(width: 8)
                .foregroundStyle(style)

            Text(timePoint(appointment.scheduledTime))
                .foregroundColor(appointment.status == .completed ? .secondary : .primary)
                .bold()
                .frame(width: 50)

            if let patient = appointment.patient {
                VStack(alignment: .leading) {
                    Text(patient.fullName)
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
                    if appointment.status == .notified {
                        HStack(spacing: 4) {
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
