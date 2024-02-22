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
    public var id: UUID = UUID()
    public var title: String = ""
    public var services: [RenderedService] = []

    public init(
        id: UUID = UUID(),
        title: String,
        services: [RenderedService] = []
    ) {
        self.id = id
        self.title = title
        self.services = services
    }
}
