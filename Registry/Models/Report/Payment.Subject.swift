//
//  Payment.Subject.swift
//  Registry
//
//  Created by Николай Фаустов on 06.03.2024.
//

import Foundation

public extension Payment {
    enum Subject: Codable, Hashable {
        case bill(Bill)
        case refund(Refund)

        var services: [RenderedService] {
            switch self {
            case .bill(let bill): return bill.services
            case .refund(let refund): return refund.services
            }
        }

        var isRefund: Bool {
            switch self {
            case .refund: return true
            default: return false
            }
        }
    }
}
