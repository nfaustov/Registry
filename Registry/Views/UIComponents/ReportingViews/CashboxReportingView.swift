//
//  CashboxReportingView.swift
//  Registry
//
//  Created by Николай Фаустов on 14.03.2024.
//

import SwiftUI
import SwiftData

struct CashboxReportingView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var selectedReporting: Reporting = .income
    @State private var cashBalance: Double = .zero
    @State private var todayReport: Report?
    @State private var lastReport: Report?
    @State private var profit: Double = .zero
    @State private var income: Double = .zero
    @State private var expense: Double = .zero
    @State private var isLoading: Bool = true
    @State private var selectedCheck: Check?

    // MARK: -

    var body: some View {
        Section {
            if isLoading {
                HStack {
                    CircularProgressView()
                        .frame(maxWidth: .infinity)
                }
            } else if let todayReport {
                LabeledContent {
                    Button("Отчет") {
                        coordinator.present(.report(todayReport))
                    }
                } label: {
                    Text("\(Int(cashBalance)) ₽")
                        .font(.title3)
                }
            } else if lastReport != nil {
                Text("\(Int(cashBalance)) ₽")
            }
        } header: {
            Text("Касса")
        }
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

        if let todayReport, let payments = todayReport.payments, !payments.isEmpty {
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
                .task {
                    income = todayReport.reporting(.income)
                    expense = todayReport.reporting(.expense)

                    if income != 0 {
                        selectedReporting = .income
                    } else if expense != 0 {
                        selectedReporting = .expense
                    }
                }

                ForEach(PaymentType.allCases, id: \.self) { type in
                    let reporting = todayReport.reporting(selectedReporting, of: type)

                    if reporting != 0 {
                        LabeledContent(type.rawValue, value: "\(Int(reporting)) ₽")
                    }
                }

                LabeledContent("Всего", value: "\(Int(selectedReporting == .income ? income : expense))")
                    .font(.headline)
            }

            Section {
                DisclosureGroup {
                    let sortedPayments = todayReport.payments?.sorted(by: { $0.date > $1.date })
                    List(sortedPayments ?? []) { payment in
                        Button {
                            selectedCheck = payment.subject
                        } label: {
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
                        .tint(.primary)
                    }
                } label: {
                    LabeledContent("Платежи") {
                        Text(profit > 0 ? "+\(Int(profit)) ₽" : "-\(Int(profit)) ₽")
                            .foregroundStyle(profit > 0 ? .green : .red)
                    }
                }
            }
            .sheet(item: $selectedCheck) { check in
                List {
                    Section("Услуги") {
                        ForEach(check.services) { service in
                            LabeledContent(service.pricelistItem.title) {
                                Text("\(Int(service.pricelistItem.price))")
                                    .frame(width: 60)
                            }
                        }
                    }

                    Section {
                        Text("Цена: \(Int(check.price)) ₽")
                            .font(.subheadline)

                        if check.discount != 0 {
                            Text("Скидка: \(Int(check.discount)) ₽")
                                .font(.subheadline)
                        }

                        Text("Оплачено: \(Int(check.totalPrice)) ₽")
                            .font(.headline)
                    } header: {
                        Text("Итог")
                    }
                }
            }
            .task {
                profit = todayReport.reporting(.profit)
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
    CashboxReportingView()
}

// MARK: - Subviews

private extension CashboxReportingView {
    func paymentBackground(_ payment: Payment) -> Color {
        payment.totalAmount > 0 ? .blue : payment.purpose == .collection ? .purple : .red
    }
}
