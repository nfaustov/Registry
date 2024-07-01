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

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @Query(todayReportDescriptor) private var reports: [Report]

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Form {
                if let todayReport = reports.first {
                    Section {
                        LabeledContent {
                            Button("Списание") {
                                coordinator.present(.createSpending(in: todayReport))
                            }
                            .disabled(user.accessLevel < .registrar)
                        } label: {
                            HStack {
                                CurrencyText(todayReport.cashBalance)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }

                Section {
                    if let todayReport = reports.first {
                        Button("Отчет") {
                            coordinator.present(.report(todayReport))
                        }
                        .tint(.primary)
                    } else {
                        Button("Открыть смену") {
                            let ledger = Ledger(modelContext: modelContext)
                            ledger.createReport()
                        }
                        .disabled(user.accessLevel < .registrar)
                    }
                }

                Section {
                    if reports.first != nil {
                        Button("Закрыть смену") {
                            let ledger = Ledger(modelContext: modelContext)
                            ledger.closeReport()
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(width: 320)

            Divider()
                .edgesIgnoringSafeArea(.all)

            if let todayReport = reports.first {
                PaymentsView(report: todayReport)
                    .padding()
                    .edgesIgnoringSafeArea([.all])
                    .disabled(user.accessLevel < .registrar)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .foregroundStyle(.white)
                    ContentUnavailableView(
                        "Нет данных",
                        systemImage: "tray.fill",
                        description: Text("Сегодня еще не было создано ни одного платежа")
                    )
                }
                .padding(.horizontal)
            }
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
    static var todayReportDescriptor: FetchDescriptor<Report> {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let endOfDay = startOfDay.addingTimeInterval(86_400)
        let predicate = #Predicate<Report> { $0.date > startOfDay && $0.date < endOfDay }
        var descriptor = FetchDescriptor<Report>(predicate: predicate)
        descriptor.fetchLimit = 1

        return descriptor
    }
}
