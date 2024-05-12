//
//  LedgerView.swift
//  Registry
//
//  Created by Николай Фаустов on 12.05.2024.
//

import SwiftUI
import SwiftData

struct LedgerView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Query private var reports: [Report]

    var ledger: Ledger!

    // MARK: - State

    @State private var selectedReport: Report?
    @State private var selection: PersistentIdentifier?
    @State private var date: Date = .now
    @State private var isLoading: Bool = true

    // MARK: -

    var body: some View {
        VStack {
            WeekdayPickerView(currentDate: $date)
                .padding(.bottom)
                .onChange(of: date) { _, newValue in
                    getReport(forDate: newValue)
                }

            if isLoading {
                CircularProgressView()
            }

            if let selectedReport {
                HStack {
                    GroupBox("Общая информация") {
                        LabeledContent("Открытие смены", value: "\(Int(selectedReport.startingCash)) ₽")
                        LabeledContent("Остаток", value: "\(Int(selectedReport.cashBalance)) ₽")
                        LabeledContent("Пополнения", value: "\(Int(selectedReport.othersIncome())) ₽")
                        LabeledContent("Инкасация", value: "\(Int(selectedReport.collected)) ₽")
                    }
                    .padding(.leading)

                    GroupBox("Поступления") {
                        LabeledContent("Наличные", value: "\(Int(selectedReport.reporting(.income, of: .cash))) ₽")
                        LabeledContent("Терминал", value: "\(Int(selectedReport.reporting(.income, of: .bank))) ₽")
                        LabeledContent("Карта", value: "\(Int(selectedReport.reporting(.income, of: .card))) ₽")
                        LabeledContent("Всего", value: "\(Int(selectedReport.reporting(.income))) ₽")
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    GroupBox("Списания") {
                        LabeledContent("Наличные", value: "\(Int(selectedReport.reporting(.expense, of: .cash))) ₽")
                        LabeledContent("Терминал", value: "\(Int(selectedReport.reporting(.expense, of: .bank))) ₽")
                        LabeledContent("Карта", value: "\(Int(selectedReport.reporting(.expense, of: .card))) ₽")
                        LabeledContent("Всего", value: "\(Int(selectedReport.reporting(.expense))) ₽")
                            .font(.headline)
                    }
                    .padding(.trailing)
                }

                let sortedPayments = selectedReport.payments?.sorted(by: { $0.date > $1.date })
                Table(sortedPayments ?? [], selection: $selection) {
                    TableColumn("Время") { payment in
                        Text(DateFormat.time.string(from: payment.date))
                    }
                    TableColumn("Назначение") { payment in
                        Text(payment.purpose.title)
                    }
                    TableColumn("Описание") { payment in
                        Text(payment.purpose.descripiton)
                    }
                    TableColumn("Оплата") { payment in
                        CurrencyText(payment.totalAmount)
                            .foregroundStyle(paymentColor(payment))
                    }
                }
                .padding()
                .sheet(item: $selection) { selection in
                    if let payment = payment(withID: selection) {
                        NavigationStack {
                            Form {
                                if let subject = payment.subject {
                                    Section("Счет") {
                                        ForEach(subject.services) { service in
                                            LabeledContent(service.pricelistItem.title, value: "\(Int(service.pricelistItem.price)) ₽" )
                                        }
                                        LabeledContent("Ощий счет", value: "\(Int(subject.totalPrice)) ₽")
                                            .font(.headline)
                                    }
                                }

                                Section("Оплата") {
                                    ForEach(payment.methods, id: \.self) { method in
                                        LabeledContent(method.type.rawValue, value: "\(Int(method.value)) ₽")
                                    }
                                    LabeledContent("Всего", value: "\(Int(payment.totalAmount)) ₽")
                                        .font(.headline)
                                }

                                Section {
                                    LabeledContent("Регистратор", value: payment.createdBy.initials)
                                }
                            }
                            .sheetToolbar(payment.purpose.title, subtitle: payment.purpose.descripiton)
                        }
                    }
                }
            }
        }
        .task {
            getReport(forDate: date)
        }
    }
}

#Preview {
    LedgerView()
}

// MARK: - Subviews

private extension LedgerView {
    func paymentColor(_ payment: Payment) -> Color {
        if payment.totalAmount < 0 {
            if payment.purpose == .collection {
                return .purple
            } else {
                return .red
            }
        } else {
            return .primary
        }
    }
}

// MARK: - Calculations

private extension LedgerView {
    func getReport(forDate date: Date) {
        isLoading = true

        Task {
            let ledger = Ledger(modelContainer: modelContext.container)
            selectedReport = await ledger.getReport(forDate: date)
            isLoading = false
        }
    }

    func payment(withID id: PersistentIdentifier) -> Payment? {
        guard let payments = selectedReport?.payments else { return nil }

        return payments.filter { $0.id == id }.first
    }
}
