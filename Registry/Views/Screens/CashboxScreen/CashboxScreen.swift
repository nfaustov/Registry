//
//  CashboxScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 22.02.2024.
//

import SwiftUI

struct CashboxScreen: View {
    // MARK: - Dependencies

    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var ledger = Ledger()

    // MARK: -

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                Form {
                    HStack {
                        Text("\(Int(ledger.todayReport.cashBalance)) ₽")
                            .fontWeight(.medium)

                        Spacer()

                        Button {
                            coordinator.present(.createSpending(in: ledger.todayReport))
                        } label: {
                            Text("Списание")
                        }
                    }
                    
                    Section {
                        DisclosureGroup("Доходы") {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if ledger.todayReport.reporting(.income, of: type) != 0 {
                                    AccountView(
                                        value: ledger.todayReport.reporting(.income, of: type),
                                        type: type,
                                        fraction: ledger.todayReport.fraction(.income, ofAccount: type)
                                    )
                                }
                            }
                        }
                        DisclosureGroup("Расходы") {
                            ForEach(PaymentType.allCases, id: \.self) { type in
                                if ledger.todayReport.reporting(.expense, of: type) != 0 {
                                    AccountView(
                                        value: ledger.todayReport.reporting(.expense, of: type),
                                        type: type,
                                        fraction: ledger.todayReport.fraction(.expense, ofAccount: type))
                                }
                            }
                        }
                    }
                    .tint(.secondary)
                    .disabled(ledger.todayReport.payments.isEmpty)

                    Button {
                        coordinator.present(.report(ledger.todayReport))
                    } label: {
                        Text("Отчет")
                    }
                    .tint(.primary)
                }
                .frame(width: 400)
            }

            Divider()
                .edgesIgnoringSafeArea(.all)

            PaymentsView(payments: ledger.todayReport.payments) { payment in
                ledger.todayReport.payments.removeAll(where: { $0 == payment })
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
