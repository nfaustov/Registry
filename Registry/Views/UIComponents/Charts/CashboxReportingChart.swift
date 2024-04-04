//
//  CashboxReportingChart.swift
//  Registry
//
//  Created by Николай Фаустов on 14.03.2024.
//

import SwiftUI
import SwiftData

struct CashboxReportingChart: View {
    // MARK: - Dependencies

    @Query(sort: \Report.date, order: .reverse) private var reports: [Report]

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var selectedReporting: Reporting = .income

    // MARK: -

    var body: some View {
        Section {
            if let todayReport = reports.first, Calendar.current.isDateInToday(todayReport.date) {
                LabeledContent {
                    Button("Отчет") {
                        coordinator.present(.report(todayReport))
                    }
                } label: {
                    Text("\(Int(reports.first?.cashBalance ?? 0)) ₽")
                        .font(.title3)
                }
            } else {
                Text("0 ₽")
            }
        } header: {
            Text("Касса")
        }

        if let todayReport = reports.first,
            Calendar.current.isDateInToday(todayReport.date),
            (todayReport.reporting(.income) != 0 || todayReport.reporting(.expense) != 0) {
            Section {
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

                if todayReport.reporting(selectedReporting, of: .bank) != 0 {
                    LabeledContent("Терминал", value: "\(Int(todayReport.reporting(selectedReporting, of: .bank)))")
                }
                if todayReport.reporting(selectedReporting, of: .cash) != 0 {
                    LabeledContent("Наличные", value: "\(Int(todayReport.reporting(selectedReporting, of: .cash)))")
                }
                if todayReport.reporting(selectedReporting, of: .card) != 0 {
                    LabeledContent("Перевод", value: "\(Int(todayReport.reporting(selectedReporting, of: .card)))")
                }
                LabeledContent("Всего", value: "\(Int(todayReport.reporting(selectedReporting)))")
                    .font(.headline)
            }

            Section {
                DisclosureGroup{
                    List(todayReport.payments.sorted(by: { $0.date > $1.date })) { payment in
                        HStack {
                            Image(systemName: payment.totalAmount > 0 ? "arrow.left" : "arrow.right")
                                .padding()
                                .background(paymentBackground(payment).opacity(0.1))
                                .clipShape(.rect(cornerRadius: 12))

                            VStack(alignment: .leading) {
                                Text(payment.purpose.title)
                                    .font(.headline)
                                Text(payment.purpose.descripiton)
                                    .font(.subheadline)
                            }

                            Spacer()

                            Text("\(Int(payment.totalAmount)) ₽")
                                .foregroundStyle(payment.totalAmount > 0 ? .teal : payment.purpose == .collection ? .purple : .red)
                        }
                    }
                } label: {
                    LabeledContent("Платежи") {
                        Text(todayReport.reporting(.profit) > 0 ? "+\(Int(todayReport.reporting(.profit))) ₽" : "-\(Int(todayReport.reporting(.profit))) ₽")
                            .foregroundStyle(todayReport.reporting(.profit) > 0 ? .green : .red)
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

#Preview {
    CashboxReportingChart()
}

// MARK: - Subviews

private extension CashboxReportingChart {
    func reportView(_ report: Report) -> some View {
        HStack {
            Text(DateFormat.date.string(from: report.date))
            Text("Доход: \(Int(report.reporting(.income))) ₽")
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color(.systemFill))
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }

    func paymentBackground(_ payment: Payment) -> Color {
        payment.totalAmount > 0 ? .blue : payment.purpose == .collection ? .purple : .red
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
}
