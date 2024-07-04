//
//  DatabaseController.swift
//  Registry
//
//  Created by Николай Фаустов on 04.07.2024.
//

import Foundation
import SwiftData

final class DatabaseController: PersistentController {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}
