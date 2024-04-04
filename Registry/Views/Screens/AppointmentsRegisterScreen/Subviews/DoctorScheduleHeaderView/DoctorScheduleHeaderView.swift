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
                PersonImageView(person: doctor)
                    .frame(width: 120, height: 150, alignment: .top)
                    .clipped()
                    .cornerRadius(12)

                VStack(alignment: .leading) {
                    Text(doctor.fullName)
                        .font(.title3).bold()
                    Text(doctor.department.specialization)

                    Spacer()

                    Label("  \(doctorSchedule.cabinet)", systemImage: "door.left.hand.closed")
                        .padding(.bottom, 4)

                    Label(duration, systemImage: "timer")
                        .padding(.bottom, 4)

                    HStack {
                        if !doctorSchedule.completedAppointments.isEmpty {
                            Label("\(doctorSchedule.completedAppointments.count)", systemImage: "person.fill.checkmark")
                            Divider()
                        }

                        Label("\(incompletedAppointments)", systemImage: "person.badge.clock.fill")

                        if doctorSchedule.availableAppointments > 0 {
                            Divider()
                            Label("\(doctorSchedule.availableAppointments)", systemImage: "person")
                        }
                    }
                    .frame(height: 20)
                }
                .font(.subheadline)

                Spacer()

                Menu {
                    if doctor.department != .procedure {
                        Section {
                            Menu("Операции") {
                                Button("Пополнение") {
                                    coordinator.present(
                                        .refillBalance(
                                            for: Binding(get: { doctor }, set: { value in doctor.balance = value.balance })
                                        )
                                    )
                                }

                                Button("Выплата") {
                                    coordinator.present(.doctorPayout(for: doctor, disabled: incompletedAppointments > 0))
                                }
                            }

                            Button("Расписания врача") {
                                coordinator.present(.doctorFutureSchedules(doctorSchedule: doctorSchedule))
                            }
                        }
                    }

                    Button("Удалить расписание", role: .destructive) {
                        deleteSchedule()
                    }
                    .disabled(doctorSchedule.scheduledPatients.count > 0)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24)
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
    var incompletedAppointments: Int {
        doctorSchedule.scheduledPatients.count - doctorSchedule.completedAppointments.count
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
