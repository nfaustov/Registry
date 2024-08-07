//
//  LineAreaMarkChart.swift
//  Registry
//
//  Created by Николай Фаустов on 07.07.2024.
//

import SwiftUI
import Charts

struct LineAreaMarkChart: View {
    // MARK: - Dependencies

    let data: [DayIndicator]
    let color: Color

    // MARK: - State

    @State private var currentIndicator: DayIndicator?

    // MARK: -

    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("День", item.day),
                y: .value("Индикатор", item.indicator)
            )
            .foregroundStyle(color.gradient)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("День", item.day),
                y: .value("Индикатор", item.indicator)
            )
            .foregroundStyle(gradient)
            .interpolationMethod(.catmullRom)

            if let currentIndicator, currentIndicator.id == item.id {
                RuleMark(x: .value("День", currentIndicator.day))
                    .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                    .foregroundStyle(color)
                    .annotation(position: .top) {
                        VStack {
                            DateText(item.day, format: .datePickerDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.indicator, format: .number)
                                .font(.title3).bold()
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.white.shadow(.drop(radius: 1.5, y: 1)))
                        }
                    }
            }
        }
        .chartYScale(domain: 0...(Int(1.3 * Double(maxValue)) + 1))
        .chartXScale(domain: (data.first?.day ?? .now)...(data.last?.day ?? .now))
        .chartOverlay { chartOverlay($0) }
    }
}

#Preview {
    LineAreaMarkChart(data: [], color: .blue)
}

// MARK: - Subviews

private extension LineAreaMarkChart {
    var gradient: LinearGradient {
        LinearGradient(colors: [color.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
    }

    @MainActor
    var maxValue: Int {
        data.sorted(by: { $0.indicator > $1.indicator }).first?.indicator ?? 0
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
                            if let currentItem = data.first(where: { Calendar.current.isDate(date, inSameDayAs: $0.day) }) {
                                currentIndicator = currentItem
                            }
                        }
                    }
                    .onEnded { value in
                        currentIndicator = nil
                    }
            )
    }
}
