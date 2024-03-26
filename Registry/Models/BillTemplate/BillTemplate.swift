//
//  BillTemplate.swift
//  Registry
//
//  Created by Николай Фаустов on 21.02.2024.
//

import Foundation
import SwiftData

@Model
public final class BillTemplate {
    public let id: UUID = UUID()
    public var title: String = ""
    public var services: [RenderedService] = []
    public var discount: Double = Double.zero

    public init(
        id: UUID = UUID(),
        title: String,
        services: [RenderedService] = [],
        discount: Double = Double.zero
    ) {
        self.id = id
        self.title = title
        self.services = services
        self.discount = discount
    }
}
