//
//  CreateTransactionView.swift
//  Registry
//
//  Created by Николай Фаустов on 25.06.2024.
//

import SwiftUI
import SwiftData

struct CreateTransactionView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]
    @Query private var accounts: [CheckingAccount]

    let account: CheckingAccount
    let transactionKind: TransactionKind

    // MARK: - State

    @State private var counterparty: Counterparty?
    @State private var selectCounterparty: Bool = false
    @State private var purpose: AccountTransaction.Purpose
    @State private var detail: String = ""
    @State private var doctorForSalary: Doctor?
    @State private var accountForTransfer: CheckingAccount?
    @State private var amount: Double = Double.zero

    // MARK: -

    init(account: CheckingAccount, kind: TransactionKind) {
        self.account = account
        transactionKind = kind

        if transactionKind == .income {
            _purpose = State(initialValue: .income)
        } else {
            _purpose = State(initialValue: .other)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Назначение") {
                    if transactionKind == .expense {
                        Picker(purpose.rawValue, selection: $purpose) {
                            ForEach(AccountTransaction.Purpose.expenseCases, id: \.self) { purpose in
                                Text(purpose.rawValue)
                            }
                        }
                        .onChange(of: purpose) {
                            doctorForSalary = nil
                            accountForTransfer = nil
                        }

                        if purpose == .salary {
                            Menu("Выбрать врача") {
                                ForEach(doctors) { doctor in
                                    Button(doctor.initials) {
                                        doctorForSalary = doctor
                                    }
                                }
                            }
                        } else if purpose == .transferTo {
                            Menu("Выбрать счет") {
                                ForEach(accounts) { account in
                                    if account != self.account {
                                        Button {
                                            accountForTransfer = account
                                        } label: {
                                            LabeledCurrency(account.title, value: account.balance)
                                        }
                                    }
                                }
                            }
                        } else {
                            Button {
                                selectCounterparty = true
                            } label: {
                                if let counterparty {
                                    LabeledContent("Контрагент", value: counterparty.title)
                                } else {
                                    Text("Выбрать контрагента")
                                }
                            }
                        }
                    } else {
                        Text(purpose.rawValue)
                    }
                }

                MoneyFieldSection("Сумма оплаты", value: $amount) {
                    if transactionKind == .expense, amount > account.balance {
                        Text("Недостаточно средств. На счете \(Int(account.balance)) ₽")
                            .foregroundStyle(.red)
                    }
                }
            }
            .sheetToolbar(
                transactionKind.rawValue,
                subtitle: account.title,
                disabled: amount == 0 || (transactionKind == .expense && amount > account.balance)
            ) {
                if purpose == .income {
                    amount = abs(amount)
                } else {
                    amount = -abs(amount)
                }

                if let doctorForSalary {
                    detail = doctorForSalary.initials
                } else if let accountForTransfer {
                    detail = accountForTransfer.title
                    let transaction = AccountTransaction(purpose: .transferFrom, detail: account.title, amount: -amount)
                    accountForTransfer.assignTransaction(transaction)
                }

                let transaction = AccountTransaction(
                    purpose: purpose,
                    detail: detail.isEmpty ? nil : detail,
                    amount: amount,
                    counterparty: counterparty
                )
                account.assignTransaction(transaction)
            }
            .sheet(isPresented: $selectCounterparty) {
                CounterpartiesList(selectedCounterparty: $counterparty)
            }
        }
    }
}

#Preview {
    CreateTransactionView(
        account: .init(title: "", type: .bank, balance: 0),
        kind: .expense
    )
}

enum TransactionKind: String, Identifiable {
    case income = "Приход"
    case expense = "Расход"

    var id: Self {
        self
    }
}
