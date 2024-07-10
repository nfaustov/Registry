//
//  LedgerDebugView.swift
//  Registry
//
//  Created by Николай Фаустов on 12.05.2024.
//

import SwiftUI
import SwiftData

struct LedgerDebugView: View {
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
                    GroupBox {
                        LabeledCurrency("Открытие смены", value: selectedReport.startingCash)
                        LabeledCurrency("Остаток", value: selectedReport.cashBalance)
                        LabeledCurrency("Пополнения", value: selectedReport.othersIncome())
                        LabeledCurrency("Инкасация", value: selectedReport.collected)
                    } label: {
                        LabeledContent("Общая информация") {
                            if selectedReport.closed {
                                Label("Закрыт", systemImage: "checkmark")
                            } else {
                                Label("Открыт", systemImage: "xmark")
                            }
                        }
                    }
                    .padding(.leading)

                    GroupBox("Поступления") {
                        LabeledCurrency("Наличные", value: selectedReport.billsIncome(of: .cash))
                        LabeledCurrency("Терминал", value: selectedReport.billsIncome(of: .bank))
                        LabeledCurrency("Карта", value: selectedReport.billsIncome(of: .card))
                        LabeledCurrency("Всего", value: selectedReport.billsIncome())
                            .font(.headline)
                    }
                    .padding(.horizontal)

                    GroupBox("Списания") {
                        LabeledCurrency("Наличные", value: selectedReport.reporting(.expense, of: .cash))
                        LabeledCurrency("Терминал", value: selectedReport.reporting(.expense, of: .bank))
                        LabeledCurrency("Карта", value: selectedReport.reporting(.expense, of: .card))
                        LabeledCurrency("Всего", value: selectedReport.reporting(.expense))
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
                        Text(payment.purpose?.rawValue ?? "")
                    }
                    TableColumn("Описание") { payment in
                        Text(payment.details)
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
                                            LabeledCurrency(service.title, value: service.price)
                                        }
                                        LabeledCurrency("Общий счет", value: subject.totalPrice)
                                            .font(.headline)
                                    }
                                }

                                Section("Оплата") {
                                    ForEach(payment.methods, id: \.self) { method in
                                        LabeledCurrency(method.type.rawValue, value: method.value)
                                    }
                                    LabeledCurrency("Всего", value: payment.totalAmount)
                                        .font(.headline)
                                }

                                Section {
                                    LabeledContent("Регистратор", value: payment.createdBy.initials)
                                }
                            }
                            .sheetToolbar(payment.purpose?.rawValue ?? "", subtitle: payment.details)
                        }
                    }
                }
            }
        }
        .onAppear {
            getReport(forDate: date)
        }
    }
}

#Preview {
    LedgerDebugView()
}

// MARK: - Subviews

private extension LedgerDebugView {
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

private extension LedgerDebugView {
    @MainActor func getReport(forDate date: Date) {
        isLoading = true
        let ledger = Ledger(modelContext: modelContext)
        selectedReport = ledger.getReport(forDate: date)
        isLoading = false
    }

    func payment(withID id: PersistentIdentifier) -> Payment? {
        guard let payments = selectedReport?.payments else { return nil }

        return payments.filter { $0.id == id }.first
    }
}
