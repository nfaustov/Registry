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

    @Environment(\.user) private var user
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var cashBalance: Double = .zero
    @State private var todayReport: Report?
    @State private var lastReport: Report?
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
                                Text("\(Int(cashBalance)) ₽")
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
                            if lastReport != nil {
                                let newReport = Report(date: .now, startingCash: cashBalance, payments: [])
                                modelContext.insert(newReport)
                                todayReport = newReport
                            } else {
                                let firstReport = Report(date: .now, startingCash: 0, payments: [])
                                modelContext.insert(firstReport)
                                todayReport = firstReport
                            }
                        }
                        .disabled(user.accessLevel < .registrar)
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
                        isLoading = true

                        Task {
                            cashBalance = todayReport.cashBalance
                            isLoading = false
                        }
                    }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .foregroundStyle(.white)
                    if isLoading {
                        CircularProgressView()
                            .scaleEffect(1.2)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .task {
            var descriptor = FetchDescriptor<Report>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            descriptor.fetchLimit = 1
            lastReport = try? modelContext.fetch(descriptor).first

            if let lastReport, Calendar.current.isDateInToday(lastReport.date) {
                todayReport = lastReport
            }

            cashBalance = lastReport?.cashBalance ?? 0

            isLoading = false
        }
    }
}

#Preview {
    CashboxScreen()
        .environmentObject(Coordinator())
        .previewInterfaceOrientation(.landscapeRight)
}
