//
//  CashboxScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI
import SwiftData
import Charts

struct CashboxScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    // MARK: - State

    @State private var selectedReporting: Reporting = .income
    @State private var selectedAngle: Double?
    @State private var selectedPaymentType: PaymentType?
    @State private var timeRemaining = 4
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                Form {
                    Section {
                        HStack {
                            Text("\(Int(todayReport.cashBalance)) ₽")
                                .fontWeight(.medium)

                            Spacer()

                            Button {
                                coordinator.present(.createSpending(in: todayReport))
                            } label: {
                                Text("Списание")
                            }
                        }
                    }

                    if todayReport.reporting(.income) != 0 || todayReport.reporting(.expense) != 0 {
                        Section {
                            VStack {
                                reportingPicker
                                reportingChart
                            }
                        }
                    }

                    Button {
                        coordinator.present(.report(todayReport))
                    } label: {
                        Text("Отчет")
                    }
                    .tint(.primary)
                }
                .frame(width: 320)
            }

            Divider()
                .edgesIgnoringSafeArea(.all)

            PaymentsView(payments: todayReport.payments) { payment in
                todayReport.payments.removeAll(where: { $0 == payment })
            }
            .padding()
            .edgesIgnoringSafeArea([.all])
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    CashboxScreen()
        .environmentObject(Coordinator())
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Subviews

private extension CashboxScreen {
    var reportingPicker: some View {
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
    }

    var reportingChart: some View {
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
    }
}

// MARK: - Calculations

private extension CashboxScreen {
    var todayReport: Report {
        if let report = reports.first {
            if Calendar.current.isDateInToday(report.date) {
                return report
            } else {
                let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [])
                modelContext.insert(newReport)

                return newReport
            }
        } else {
            let firstReport = Report(date: .now, startingCash: 0, payments: [])
            modelContext.insert(firstReport)

            return firstReport
        }
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
            cumulativeTotal += abs(todayReport.reporting(selectedReporting, of: type))
            if value <= cumulativeTotal {
                selectedPaymentType = type
                return true
            }

            return false
        }
    }
}
