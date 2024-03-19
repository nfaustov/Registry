//
//  CashboxReportingChart.swift
//  Registry
//
//  Created by Николай Фаустов on 14.03.2024.
//

import SwiftUI
import SwiftData
import Charts

struct CashboxReportingChart: View {
    // MARK: - Dependencies

    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    // MARK: - State

    @State private var selectedReporting: Reporting = .income
    @State private var selectedAngle: Double?
    @State private var selectedPaymentType: PaymentType?
    @State private var timeRemaining = 4

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Касса")
                    .font(.title)

                Spacer()

                Text("\(Int(todayReport?.cashBalance ?? 0)) ₽")
                    .font(.title)
            }
            .padding(.vertical, 8)

            if let todayReport, todayReport.reporting(.income) != 0 || todayReport.reporting(.expense) != 0 {
                Picker("Тип операции", selection: $selectedReporting) {
                    ForEach(Reporting.allCases) { reporting in
                        if reporting != .profit {
                            Text(reporting.rawValue)
                        }
                    }
                }
                .pickerStyle(.segmented)
                .disabled(todayReport.reporting(.income) == 0 || todayReport.reporting(.expense) == 0)
                .onAppear {
                    if todayReport.reporting(.income) != 0 {
                        selectedReporting = .income
                    } else if todayReport.reporting(.expense) != 0 {
                        selectedReporting = .expense
                    }
                }

                Chart(PaymentType.allCases, id: \.rawValue) { type in
                    SectorMark(
                        angle: .value("Доходы/Расходы", abs(todayReport.reporting(selectedReporting, of: type))),
                        innerRadius: .ratio(0.618),
                        outerRadius: selectedPaymentType == type ? 120 : 108,
                        angularInset: 1.5
                    )
                    .cornerRadius(4)
                    .foregroundStyle(chartStyle(type))
                    .opacity(type == selectedPaymentType ? 1 : 0.5)
                }
                .chartAngleSelection(value: $selectedAngle)
                .chartBackground { _ in
                    VStack {
                        if let selectedPaymentType {
                            Text(selectedPaymentType.rawValue)
                                .contentTransition(.identity)
                        }
                        Text("\(Int(todayReport.reporting(selectedReporting, of: selectedPaymentType))) ₽")
                            .font(.title)
                            .contentTransition(.numericText())
                    }
                }
                .frame(height: 240)
                .onChange(of: selectedAngle) { _, newValue in
                    if let newValue {
                        withAnimation {
                            getSelectedPaymentType(value: newValue)
                            timeRemaining = 4
                        }
                    }
                }
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else if timeRemaining == 0 {
                        withAnimation {
                            selectedPaymentType = nil
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "Нет данных",
                    systemImage: "chart.pie",
                    description: Text("За выбранный период не совершено ни одного платежа")
                )
            }
        }
    }
}

#Preview {
    CashboxReportingChart()
}

// MARK: - Calculations

private extension CashboxReportingChart {
    var todayReport: Report? {
        if let report = reports.first, Calendar.current.isDateInToday(report.date) {
            return report
        } else { return nil }
    }

    func chartStyle(_ type: PaymentType) -> Color {
        switch type {
        case .cash:
            return .orange
        case .bank:
            return .purple
        case .card:
            return .green
        }
    }

    func getSelectedPaymentType(value: Double) {
        var cumulativeTotal = 0.0
        _ = PaymentType.allCases.first { type in
            cumulativeTotal += abs(todayReport?.reporting(selectedReporting, of: type) ?? 0)
            if value <= cumulativeTotal {
                selectedPaymentType = type
                return true
            }

            return false
        }
    }
}
