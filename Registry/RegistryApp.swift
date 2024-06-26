//
//  RegistryApp.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI
import SwiftData

@main
struct RegistryApp: App {
    @StateObject private var coordinator = Coordinator()
    @StateObject private var scheduleController = ScheduleController()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([DoctorSchedule.self, CheckingAccount.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .environmentObject(scheduleController)
        }
        .modelContainer(sharedModelContainer)
    }
}
