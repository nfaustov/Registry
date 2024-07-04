//
//  PersistentController.swift
//  Registry
//
//  Created by Николай Фаустов on 04.07.2024.
//

import Foundation
import SwiftData

@MainActor
protocol PersistentController: AnyObject {
    var modelContext: ModelContext { get }

    func getModels<T>(predicate: Predicate<T>?) -> [T] where T: PersistentModel
    func getModel<T>(predicate: Predicate<T>?, sortBy: [SortDescriptor<T>]) -> T? where T: PersistentModel
}

extension PersistentController {
    func getModels<T>(predicate: Predicate<T>? = nil) -> [T] where T: PersistentModel {
        let descriptor = FetchDescriptor<T>(predicate: predicate)

        if let models = try? modelContext.fetch(descriptor) {
            return models
        } else { return [] }
    }

    func getModel<T>(predicate: Predicate<T>? = nil, sortBy sort: [SortDescriptor<T>] = []) -> T? where T: PersistentModel {
        var descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sort)
        descriptor.fetchLimit = 1

        return try? modelContext.fetch(descriptor).first
    }
}
