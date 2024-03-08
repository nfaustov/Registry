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

    @State private var selectedReporting: Reporting = .income

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                Form {
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

                    if todayReport.reporting(.income) != 0 || todayReport.reporting(.expense) != 0 {
                        reportingSection()
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
    @ViewBuilder func reportingSection() -> some View {
        Section {
            VStack {
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
                        angle: .value("Доходы", todayReport.reporting(selectedReporting, of: type)),
                        innerRadius: .ratio(0.618),
                        angularInset: 1.5
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Тип оплаты", type.rawValue))
                }
                .frame(height: 240)
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
}
