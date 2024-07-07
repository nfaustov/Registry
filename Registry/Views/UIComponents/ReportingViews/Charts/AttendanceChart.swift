//
//  AttendanceChart.swift
//  Registry
//
//  Created by Николай Фаустов on 07.07.2024.
//

import SwiftUI
import Charts

struct AttendanceChart: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    let date: Date
    let selectedPeriod: StatisticsPeriod

    // MARK: - State

    @State private var currentAttendance: Attendance?

    // MARK: -

    var body: some View {
        Chart(attendanceData, id: \.self) { attendance in
            LineMark(
                x: .value("День", attendance.day),
                y: .value("Посещаемость", attendance.patientsCount)
            )
            .foregroundStyle(.blue.gradient)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("День", attendance.day),
                y: .value("Посещаемость", attendance.patientsCount)
            )
            .foregroundStyle(gradient)
            .interpolationMethod(.catmullRom)

            if let currentAttendance, currentAttendance.id == attendance.id {
                RuleMark(x: .value("День", currentAttendance.day))
                    .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                    .annotation(position: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Пациентов")
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Text(attendance.patientsCount, format: .number)
                                .font(.title3).bold()
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(.white.shadow(.drop(radius: 2, y: 1)))
                        }
                    }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .stride(by: .day)) {
                AxisValueLabel(format: .dateTime.day(.twoDigits))
            }
        }
        .chartYScale(domain: 0...(maxPatients + 20))
        .chartXScale(domain: selectedPeriod.start(for: date)...selectedPeriod.end(for: date))
        .chartOverlay { proxy in
            chartOverlay(proxy)
        }
        .frame(height: 100)
    }
}

#Preview {
    AttendanceChart(date: .now, selectedPeriod: .week)
}

// MARK: - Subviews

private extension AttendanceChart {
    var gradient: LinearGradient {
        LinearGradient(colors: [.blue.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
    }

    @MainActor
    var maxPatients: Int {
        attendanceData.sorted(by: { $0.patientsCount > $1.patientsCount }).first?.patientsCount ?? 0
    }

    @MainActor
    func chartOverlay(_ proxy: ChartProxy) -> some View {
        Rectangle()
            .fill(.clear).contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let location = value.location

                        if let date: Date = proxy.value(atX: location.x) {
                            if let currentItem = attendanceData.first(where: { Calendar.current.isDate(date, inSameDayAs: $0.day) }) {
                                currentAttendance = currentItem
                            }
                        }
                    }
                    .onEnded { value in
                        currentAttendance = nil
                    }
            )
    }
}

// MARK: - Calculation

private extension AttendanceChart {
    @MainActor
    var attendanceData: [Attendance] {
        let ledger = Ledger(modelContext: modelContext)
        return ledger.attendance(for: date, period: selectedPeriod)
    }
}
