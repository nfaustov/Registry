//
//  MoneyTransaction.swift
//  Registry
//
//  Created by Николай Фаустов on 07.05.2024.
//

import Foundation

protocol MoneyTransaction {
    associatedtype Kind: MoneyTransactionKind

    var date: Date { get }
    var description: String? { get }
    var value: Double { get }
    var kind: Kind { get }
    var refunded: Bool { get }
}

protocol MoneyTransactionKind {
    var title: String { get }
}
