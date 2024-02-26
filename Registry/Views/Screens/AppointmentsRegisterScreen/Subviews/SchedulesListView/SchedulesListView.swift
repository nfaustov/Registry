//
//  SchedulesListView.swift
//  Registry
//
//  Created by Николай Фаустов on 23.02.2024.
//

import SwiftUI

struct SchedulesListView: View {
    // MARK: - Dependencies

    let schedules: [DoctorSchedule]

    // MARK: - State

    @Binding var selectedSchedule: DoctorSchedule?

    // MARK: -

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(schedules) { schedule in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(schedule.doctor?.fullName ?? "")
                                .lineLimit(2)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        
                        Text(schedule.doctor?.department.specialization ?? "")
                            .font(.callout)
                            .foregroundColor(.secondary)

                        HStack(alignment: .top, spacing: 8) {
                            Spacer()
                            Text(scheduleBounds(schedule))
                        }
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(gradient, lineWidth: 1)
                    )
                    .background(
                        selectedSchedule?.id == schedule.id ? .blue.opacity(0.2) :
                            Color(.tertiarySystemGroupedBackground)
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        if selectedSchedule?.id != schedule.id {
                            selectedSchedule = schedule
                        }
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    SchedulesListView(schedules: [ExampleData.doctorSchedule], selectedSchedule: .constant(nil))
}

// MARK: - Calculations

private extension SchedulesListView {
    var gradient: AngularGradient {
        AngularGradient(gradient: Gradient(colors: [.secondary.opacity(0.7), .clear, .clear, .secondary.opacity(0.7)]), center: .center, angle: .degrees(90))
    }

    func scheduleBounds(_ schedule: DoctorSchedule) -> String {
        DateFormatter.shared.dateFormat = "H:mm"
        let starting = DateFormatter.shared.string(from: schedule.starting)
        let ending = DateFormatter.shared.string(from: schedule.ending)
        return "\(starting) - \(ending)"
    }
}
