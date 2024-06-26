//
//  AccountsView.swift
//  Registry
//
//  Created by Николай Фаустов on 15.06.2024.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var coordinator: Coordinator

    @Query(sort: [SortDescriptor(\CheckingAccount.balance, order: .reverse)])
    private var accounts: [CheckingAccount]
    @Query(filter: #Predicate<Patient> { $0.balance != 0 })
    private var patients: [Patient]
    @Query(filter: #Predicate<Doctor> { $0.balance != 0 })
    private var doctors: [Doctor]

    // MARK: - State

    @State private var cashboxBalance: Double = .zero

    // MARK: -

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 4) {
                Button {
                    coordinator.present(.allTransactions)
                } label: {
                    accountView("Баланс", amount: overallBalance)
                }
                .buttonStyle(AccountButtonStyle(color: overallBalance < 0 ? .pink : .teal))

                ForEach(accounts) { account in
                    Button {
                        coordinator.present(.accountDetail(account: account))
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                accountImage(account)
                                Text(account.title)
                                    .font(.caption)
                            }

                            CurrencyText(account.balance)
                                .font(.headline)
                        }
                    }
                    .buttonStyle(AccountButtonStyle(color: .blue))
                }

                Button {
                    
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "rublesign.square")
                            Text("Касса")
                                .font(.caption)
                        }

                        CurrencyText(cashboxBalance)
                            .font(.headline)
                    }
                }
                .buttonStyle(AccountButtonStyle(color: .cyan))
                .onAppear {
                    let ledger = Ledger(modelContext: modelContext)

                    if let report = ledger.getReport() {
                        cashboxBalance = report.cashBalance
                    }
                }

                Button {
                    coordinator.present(.balanceDetail(persons: doctors))
                } label: {
                    accountView("Баланс врачей", amount: doctorsBalance)
                }
                .buttonStyle(AccountButtonStyle(color: .cyan))

                Button {
                    coordinator.present(.balanceDetail(persons: patients))
                } label: {
                    accountView("Баланс пациентов", amount: patientsBalance)
                }
                .buttonStyle(AccountButtonStyle(color: .cyan))
            }
        }
    }
}

#Preview {
    AccountsView()
}

// MARK: - Calculations

private extension AccountsView {
    var patientsBalance: Double {
        patients.reduce(0.0) { $0 + $1.balance }
    }

    var doctorsBalance: Double {
        doctors.reduce(0.0) { $0 + $1.balance}
    }

    var overallBalance: Double {
        let accountsBalance = accounts.reduce(0.0) { $0 + $1.balance }
        return accountsBalance - patientsBalance - doctorsBalance
    }
}

// MARK: - Subviews

private extension AccountsView {
    func accountImage(_ account: CheckingAccount) -> some View {
        switch account.type {
        case .cash: Image(systemName: "banknote")
        case .card: Image(systemName: "creditcard")
        case .bank: Image(systemName: "building.columns.circle")
        case .credit: Image(systemName: "rublesign.arrow.circlepath")
        }
    }

    func accountView(_ title: String, amount: Double) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
            CurrencyText(amount)
                .font(.headline)
        }
    }
}

struct AccountButtonStyle: ButtonStyle {

    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .frame(width: 152, alignment: .leading)
            .frame(maxHeight: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.5 : 0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .foregroundStyle(color)
    }
}
