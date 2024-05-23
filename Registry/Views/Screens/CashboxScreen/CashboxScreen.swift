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

    // MARK: - State

    @State private var todayReport: Report?
    @State private var isLoading: Bool = true

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Form {
                if let todayReport {
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
                                if isLoading {
                                    CircularProgressView()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }

                Section {
                    if let todayReport {
                        Button("Отчет") {
                            coordinator.present(.report(todayReport))
                        }
                        .tint(.primary)
                    } else {
                        Button("Открыть смену") {
                            Task {
                                let ledger = Ledger(modelContainer: modelContext.container)
                                await ledger.createReport()
                                todayReport = await ledger.getReport()
                            }
                        }
                        .disabled(user.accessLevel < .registrar || isLoading)
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(width: 320)

            Divider()
                .edgesIgnoringSafeArea(.all)

            if let todayReport {
                PaymentsView(report: todayReport)
                    .padding()
                    .edgesIgnoringSafeArea([.all])
                    .disabled(user.accessLevel < .registrar)
                    .onChange(of: todayReport.payments) {
                        Task {
                            let ledger = Ledger(modelContainer: modelContext.container)
                            self.todayReport = await ledger.getReport()
                        }
                    }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .foregroundStyle(.white)
                    if isLoading {
                        CircularProgressView()
                            .scaleEffect(1.2)
                    } else {
                        ContentUnavailableView(
                            "Нет данных",
                            systemImage: "tray.fill",
                            description: Text("Сегодня еще не было создано ни одного платежа")
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .task {
            let ledger = Ledger(modelContainer: modelContext.container)
            todayReport = await ledger.getReport()
            isLoading = false
        }
    }
}

#Preview {
    CashboxScreen()
        .environmentObject(Coordinator())
        .previewInterfaceOrientation(.landscapeRight)
}
