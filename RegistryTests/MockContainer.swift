//
//  MockContainer.swift
//  RegistryTests
//
//  Created by Николай Фаустов on 09.05.2024.
//

import Foundation
import SwiftData

@MainActor
var mockContainer: ModelContainer {
    do {
        let schema = Schema([DoctorSchedule.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}


