//
//  BarMarkChart.swift
//  Registry
//
//  Created by Николай Фаустов on 18.07.2024.
//

import SwiftUI
import Charts

struct BarMarkChart: View {
    // MARK: - Dependencies

    let data: [DayIndicator]
    let color: Color

    // MARK: - State

    @State private var showAnnotation: Bool = false

    // MARK: -

    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("День", item.day, unit: .day),
                y: .value("Индикатор", item.indicator)
            )
            .foregroundStyle(color.gradient)
            .opacity(Calendar.current.isDate(item.day, inSameDayAs: .now) ? 0.4 : 1)
            .annotation(position: .overlay, alignment: .top) {
                if showAnnotation && item.indicator > 0 {
                    Text(item.indicator, format: .number)
                        .font(.title3).bold()
                        .foregroundStyle(.white.gradient)
                        .padding(4)
                }
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) {
                AxisValueLabel(centered: true)
            }
        }
        .chartYScale(domain: 0...(Int(1.3 * Double(maxValue)) + 1))
        .chartOverlay { _ in chartOverlay }
    }
}

#Preview {
    BarMarkChart(data: [], color: .blue)
}

// MARK: - Subviews

private extension BarMarkChart {
    @MainActor
    var maxValue: Int {
        data.sorted(by: { $0.indicator > $1.indicator }).first?.indicator ?? 0
    }

    @MainActor
    var chartOverlay: some View {
        Rectangle()
            .fill(.clear).contentShape(Rectangle())
            .onTapGesture {
                showAnnotation.toggle()
            }
    }
}
