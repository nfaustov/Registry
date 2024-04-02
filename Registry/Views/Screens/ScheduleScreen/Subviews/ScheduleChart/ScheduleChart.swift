//
//  ScheduleChart.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI
import Charts

struct ScheduleChart: View {
    // MARK: - Dependencies

    let schedules: [DoctorSchedule]
    let date: Date

    // MARK: -

    var body: some View {
        ScrollView(.vertical) {
            Chart(schedules) { schedule in
                if let doctor = schedule.doctor {
                    BarMark(
                        xStart: .value(
                            "ScheduleStarting",
                            schedule.starting,
                            unit: .minute
                        ),
                        xEnd: .value(
                            "ScheduleEnding",
                            schedule.ending,
                            unit: .minute
                        ),
                        y: .value("Doctor", doctor.initials),
                        height: .ratio(0.3)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .foregroundStyle(schedule.ending <= Date.now ? .gray : doctor.department == .procedure ? .clear : .blue)
                }

                if workingHours.range.contains(.now) {
                    RuleMark(x: .value("TimeNow", Date.now))
                        .foregroundStyle(.primary.opacity(0.3))
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .hour)) {
                    AxisGridLine()
                    AxisValueLabel(
                        format: .dateTime.hour().locale(Locale(identifier: "RU_ru"))
                    )
                }
            }
            .chartYAxis {
                AxisMarks(preset: .extended, position: .leading) { value in
                    AxisValueLabel(centered: true)
                        .font(.subheadline)
                        .foregroundStyle(Color(.label))
                }
            }
            .chartXScale(
                domain: workingHours.range,
                range: .plotDimension(padding: 16))
            .chartPlotStyle { plotArea in
                plotArea.frame(height: 64 * CGFloat(todayDoctors.count))
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    ScheduleChart(schedules: [ExampleData.doctorSchedule], date: .now)
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Calculations

extension ScheduleChart {
    var workingHours: WorkingHours {
        WorkingHours(for: date)
    }

    var todayDoctors: [Doctor] {
        Array(
            schedules
                .compactMap { $0.doctor }
                .uniqued()
        )
        
    }
}
