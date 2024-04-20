//
//  Visit.swift
//  Registry
//
//  Created by Николай Фаустов on 20.02.2024.
//

import Foundation

//extension RegistrySchemaV1 {
//    struct Visit: Codable, Hashable, Identifiable {
//        let id: UUID
//        let registrationDate: Date
//        let registrar: AnyUser
//        var visitDate: Date
//        var cancellationDate: Date?
//        var bill: Bill?
//        var refund: Refund?
//
//        init(
//            id: UUID = UUID(),
//            registrar: AnyUser,
//            visitDate: Date,
//            cancellationDate: Date? = nil,
//            bill: Bill? = nil,
//            refund: Refund? = nil
//        ) {
//            self.id = id
//            self.registrationDate = .now
//            self.registrar = registrar
//            self.visitDate = visitDate
//            self.cancellationDate = cancellationDate
//            self.bill = bill
//            self.refund = refund
//        }
//    }
//
//    struct Bill: Codable, Hashable, Identifiable {
//        let id: UUID
//        var services: [RenderedService]
//        var discount: Double
//        private(set) var contract: Data?
//
//        var price: Double {
//            services
//                .map { $0.pricelistItem.price }
//                .reduce(0.0, +)
//        }
//
//        var totalPrice: Double {
//            price - discount
//        }
//
//        var discountRate: Double {
//            guard price != 0 else { return 0 }
//            return discount / price
//        }
//
//        init(
//            id: UUID = UUID(),
//            services: [RenderedService],
//            discount: Double = 0,
//            contract: Data? = nil
//        ) {
//            self.id = id
//            self.services = services
//            self.discount = discount
//            self.contract = contract
//        }
//    }
//
//    struct Refund: Codable, Hashable, Identifiable {
//        let id: UUID
//        let date: Date
//        var services: [RenderedService]
//
//        var price: Double {
//            services
//                .map { $0.pricelistItem.price }
//                .reduce(0.0, +)
//        }
//
//        func totalAmount(discountRate rate: Double) -> Double {
//            rate * price - price
//        }
//
//        init(id: UUID = UUID(), services: [RenderedService]) {
//            self.id = id
//            self.date = .now
//            self.services = services
//        }
//    }
//
//    struct RenderedService: Codable, Hashable, Identifiable {
//        let id: UUID
//        let pricelistItem: PricelistItem.Short
//        var performer: AnyEmployee?
//        var agent: AnyEmployee?
//        private(set) var conclusion: Data?
//
//        init(
//            id: UUID = UUID(),
//            pricelistItem: PricelistItem.Short,
//            performer: AnyEmployee?,
//            agent: AnyEmployee? = nil,
//            conclusion: Data? = nil
//        ) {
//            self.id = id
//            self.pricelistItem = pricelistItem
//            self.performer = performer
//            self.agent = agent
//            self.conclusion = conclusion
//        }
//    }
//}
//
//extension RegistrySchemaV2 {
//    struct Visit: Codable, Hashable, Identifiable {
//        let id: UUID
//        let registrationDate: Date
//        let registrar: AnyUser
//        var visitDate: Date
//        var cancellationDate: Date?
//        var bill: Bill?
//        var refund: Refund?
//
//        init(
//            id: UUID = UUID(),
//            registrar: AnyUser,
//            visitDate: Date,
//            cancellationDate: Date? = nil,
//            bill: Bill? = nil,
//            refund: Refund? = nil
//        ) {
//            self.id = id
//            self.registrationDate = .now
//            self.registrar = registrar
//            self.visitDate = visitDate
//            self.cancellationDate = cancellationDate
//            self.bill = bill
//            self.refund = refund
//        }
//
//        struct Refund: Codable, Hashable, Identifiable {
//            let id: UUID
//            let date: Date
//            var services: [RenderedService]
//
//            var price: Double {
//                services
//                    .map { $0.pricelistItem.price }
//                    .reduce(0.0, +)
//            }
//
//            func totalAmount(discountRate rate: Double) -> Double {
//                rate * price - price
//            }
//
//            init(id: UUID = UUID(), services: [RenderedService]) {
//                self.id = id
//                self.date = .now
//                self.services = services
//            }
//        }
//    }
//
//    struct Bill: Codable, Hashable, Identifiable {
//        let id: UUID
//        var services: [RenderedService]
//        var discount: Double
//        private(set) var contract: Data?
//
//        var price: Double {
//            services
//                .map { $0.pricelistItem.price }
//                .reduce(0.0, +)
//        }
//
//        var totalPrice: Double {
//            price - discount
//        }
//
//        var discountRate: Double {
//            guard price != 0 else { return 0 }
//            return discount / price
//        }
//
//        init(
//            id: UUID = UUID(),
//            services: [RenderedService],
//            discount: Double = 0,
//            contract: Data? = nil
//        ) {
//            self.id = id
//            self.services = services
//            self.discount = discount
//            self.contract = contract
//        }
//    }
//
//    struct RenderedService: Codable, Hashable, Identifiable {
//        let id: UUID
//        let pricelistItem: PricelistItem.Short
//        var performer: RegistrySchemaV1.AnyEmployee?
//        var agent: RegistrySchemaV1.AnyEmployee?
//        private(set) var conclusion: Data?
//
//        init(
//            id: UUID = UUID(),
//            pricelistItem: PricelistItem.Short,
//            performer: RegistrySchemaV1.AnyEmployee?,
//            agent: RegistrySchemaV1.AnyEmployee? = nil,
//            conclusion: Data? = nil
//        ) {
//            self.id = id
//            self.pricelistItem = pricelistItem
//            self.performer = performer
//            self.agent = agent
//            self.conclusion = conclusion
//        }
//    }
//}
