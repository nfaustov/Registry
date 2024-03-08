//
//  DoctorScheduleHeaderView.swift
//  Registry
//
//  Created by Николай Фаустов on 23.02.2024.
//

import SwiftUI

struct DoctorScheduleHeaderView: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator

    let doctorSchedule: DoctorSchedule
    let deleteSchedule: () -> Void

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            if let doctor = doctorSchedule.doctor {
                DoctorImageView(doctor: doctor)
                    .frame(width: 120, height: 150, alignment: .top)
                    .clipped()
                    .cornerRadius(12)

                VStack(alignment: .leading) {
                    Text(doctor.fullName)
                        .font(.title3).bold()
                    Text(doctor.department.specialization)

                    Spacer()

                    Label("  \(doctorSchedule.cabinet)", systemImage: "door.left.hand.closed")
                        .padding(.vertical, 4)
                    Label(duration, systemImage: "timer")
                }
                .font(.subheadline)

                Spacer()

                Menu {
                    if doctor.department != .procedure {
                        Section {
                            Button("Рассчитать врача") {
                                if let doctor = doctorSchedule.doctor {
                                    coordinator.present(.doctorPayout(for: doctor))
                                }
                            }
                            .disabled(!allAppointmentsCompleted || doctor.balance == 0)

                            Button("Расписания врача") {
                                coordinator.present(.doctorFutureSchedules(doctorSchedule: doctorSchedule))
                            }
                        }
                    }

                    Button("Удалить расписание", role: .destructive) {
                        deleteSchedule()
                    }
                    .disabled(hasScheduledPatients)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                }
            }
        }
    }
}

#Preview {
    DoctorScheduleHeaderView(doctorSchedule: ExampleData.doctorSchedule, deleteSchedule: { })
        .frame(height: 150)
}

// MARK: - Calculations

private extension DoctorScheduleHeaderView {
    var allAppointmentsCompleted: Bool {
        doctorSchedule.scheduledPatients == doctorSchedule.patientAppointments
            .filter { $0.status == .completed }
            .count
    }

    var hasScheduledPatients: Bool {
        !doctorSchedule.patientAppointments
            .filter { $0.status != .cancelled }
            .compactMap { $0.patient }
            .isEmpty
    }

    var duration: String {
        guard let doctor = doctorSchedule.doctor else { return "" }
        let hours = Int(doctor.serviceDuration / 3600)
        let minutes = (Int(doctor.serviceDuration) % 3600) / 60

        var result = hours > 0 ? "\(hours) ч. " : ""

        if minutes > 0 {
            result += "\(minutes) мин."
        }

        return result
    }
}
