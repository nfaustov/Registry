//
//  CashboxScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI
import SwiftData

struct CashboxScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @Query(descriptor) private var reports: [Report]

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                Form {
                    HStack {
                        Text("\(Int(report.cashBalance)) ₽")
                            .fontWeight(.medium)

                        Spacer()

                        Button {
                            coordinator.present(.createSpending(in: report))
                        } label: {
                            Text("Списание")
                        }
                    }
                    
                    Section {
                        DisclosureGroup("Доходы") {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if report.reporting(.income, of: type) != 0 {
                                    AccountView(
                                        value: report.reporting(.income, of: type),
                                        type: type,
                                        fraction: report.fraction(.income, ofAccount: type)
                                    )
                                }
                            }
                        }
                        DisclosureGroup("Расходы") {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if report.reporting(.expense, of: type) != 0 {
                                    AccountView(
                                        value: report.reporting(.expense, of: type),
                                        type: type,
                                        fraction: report.fraction(.expense, ofAccount: type))
                                }
                            }
                        }
                    }
                    .tint(.secondary)
                    .disabled(report.payments.isEmpty)

                    Button {
                        coordinator.present(.report(report))
                    } label: {
                        Text("Отчет")
                    }
                    .tint(.primary)
                }
                .frame(width: 400)
            }

            Divider()
                .edgesIgnoringSafeArea(.all)

            PaymentsView(payments: report.payments) { payment in
                report.payments.removeAll(where: { $0 == payment })
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

// MARK: - Calculations

private extension CashboxScreen {
    static var descriptor: FetchDescriptor<Report> {
        var descriptor = FetchDescriptor<Report>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return descriptor
    }

    var report: Report {
        if let report = reports.first {
            if Calendar.current.isDateInToday(report.date) {
                return report
            } else {
                let newReport = Report(date: .now, startingCash: report.cashBalance, payments: [])
                modelContext.insert(newReport)
                return newReport
            }
        } else {
            let firstReport = ExampleData.report
            modelContext.insert(firstReport)
            return firstReport
        }
    }
}
