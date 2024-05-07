//
//  DoctorTransactionsView.swift
//  Registry
//
//  Created by Николай Фаустов on 06.05.2024.
//

import SwiftUI

struct DoctorTransactionsView: View {
    // MARK: - Dependencies

    let doctor: Doctor

    // MARK: - State

    @State private var transactions: [DoctorTransactionsView.Transaction] = []

    // MARK: -

    var body: some View {
        let transactionsByDate = Dictionary(grouping: transactions, by: { $0.date })
        let dates = Array(transactionsByDate.keys.sorted(by: >))
        Form {
            ForEach(dates, id: \.self) { date in
                Section {
                    List(transactionsByDate[date] ?? [], id: \.self) { transaction in
                        VStack(alignment: .leading) {
                            Text(transaction.type.rawValue)
                                .font(.headline)
                                .foregroundStyle(transaction.value < 0 ? .purple : .teal)
                                .padding()
                            LabeledContent(transaction.description) {
                                Text(signedValueString(transaction.value))
                                    .font(.title2)
                                    .foregroundStyle(transaction.value < 0 ? .purple : .teal)
                            }
                            .padding([.bottom, .horizontal])
                        }
                        .background(transaction.value < 0 ? .purple.opacity(0.1) : .teal.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 12, style: .continuous))
                    }
                } header: {
                    DateText(date, format: .date)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            transactions = getTransactions()
        }
    }
}

#Preview {
    DoctorTransactionsView(doctor: ExampleData.doctor)
}

// MARK: - Calculations

private extension DoctorTransactionsView {
    func getTransactions() -> [DoctorTransactionsView.Transaction] {
        let performedServices = doctor.performedServices(from: .distantPast)
        let appointedServices = doctor.appointedServices(from: .distantPast)

        let performedTransactions = performedServices.map { 
            DoctorTransactionsView.Transaction(medicalService: $0, doctor: doctor, type: .performed) }
        let appointedTransactions = appointedServices.map {
            DoctorTransactionsView.Transaction(medicalService: $0, doctor: doctor, type: .appointed)
        }
        var doctorTransactions = performedTransactions
        doctorTransactions.append(contentsOf: appointedTransactions)
        if let transactions = doctor.transactions {
            let payoutsTransactions = transactions.map {
                DoctorTransactionsView.Transaction(payment: $0)
            }
            doctorTransactions.append(contentsOf: payoutsTransactions)
        }

        return doctorTransactions
    }

    func signedValueString(_ value: Double) -> String {
        var signedString = "\(Int(value))"

        if value > 0 {
            signedString.insert("+", at: signedString.startIndex)
        }

        return signedString
    }
}

// MARK: - Transaction

private extension DoctorTransactionsView {
    struct Transaction: Hashable {
        let date: Date
        let description: String
        let value: Double
        let type: DoctorTransactionsView.TransactionType

        init(medicalService: MedicalService, doctor: Doctor, type: DoctorTransactionsView.TransactionType) {
            date = medicalService.date ?? .now
            description = medicalService.pricelistItem.title

            if medicalService.refund != nil {
                value = 0
            } else {
                switch type {
                case .appointed:
                    value = medicalService.agentFee
                case .performed:
                    if let rate = doctor.doctorSalary.rate {
                        value = medicalService.pieceRateSalary(rate)
                    } else {
                        value = 0
                    }
                default: value = 0
                }
            }

            self.type = type
        }

        init(payment: Payment) {
            date = payment.date
            description = ""
            value = payment.methods.reduce(0.0) { $0 + $1.value }

            if payment.purpose.title == "Выплата" {
                type = .payout
            } else if payment.purpose.title == "Пополнение баланса" {
                type = .refill
            } else {
                fatalError()
            }
        }
    }

    enum TransactionType: String {
        case appointed = "Агентские"
        case performed = "Заработная плата"
        case payout = "Выплата"
        case refill = "Пополнение"
    }
}
