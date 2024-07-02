//
//  PurposeExpense.swift
//  Registry
//
//  Created by Николай Фаустов on 02.07.2024.
//

import Foundation

struct PurposeExpense: Hashable {
    let category: ExpenseCategory
    var amount: Double
}

enum ExpenseCategory: String, CaseIterable {
    case dividends = "Дивиденды"
    case doctorPayout = "Выплаты врачам"
    case refund = "Возвраты"
    case laboratory = "Лаборатория"
    case equipment = "Оборудование"
    case consumables = "Расходники"
    case building = "Помещение"
    case taxes = "Налоги"
    case advertising = "Реклама"
    case loan = "Кредит"
    case banking = "Банковские услуги"
    case other = "Прочее"
}
