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
                .foregroundColor(Color(.systemFill))

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
//                        coordinator.present(.completedAppointment(appointment: appointment))
                    } label: {
                        HStack {
                            Text(appointment.status.rawValue)
                                .foregroundColor(.secondary)
                            Image(systemName: "info.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20)
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    Picker("", selection: $appointment.status) {
                        ForEach(PatientAppointment.Status.allCases) { status in
                            Text(status.rawValue)
                                .tag(status.rawValue)
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
}
