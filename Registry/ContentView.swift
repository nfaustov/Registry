//
//  ContentView.swift
//  Registry
//
//  Created by Николай Фаустов on 22.12.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Dependencies

//    @Environment(\.modelContext) private var modelContext
//    @Query private var pricelistItems: [PricelistItem]
//    @Query private var schedules: [DoctorSchedule]
//    @Query private var doctors: [Doctor]
//    @Query private var patients: [Patient]

    @EnvironmentObject private var coordinator: Coordinator

    // MARK: - State

    @State private var rootScreen: Screen? = .schedule
    @State private var user: User? = nil

    // MARK: -

    var body: some View {
        if let user {
            NavigationSplitView {
                if user.accessLevel == .boss {
                    IndicatorsList()
                } else {
                    RegistrarSidebar(rootScreen: $rootScreen)
                }
            } detail: {
                NavigationStack(path: $coordinator.path) {
                    coordinator.setRootView(rootScreen ?? .schedule)
                        .navigationTitle(rootScreen?.title ?? Screen.schedule.title)
                        .navigationDestination(for: Route.self) { coordinator.destinationView($0) }
                        .sheet(item: $coordinator.sheet) { coordinator.sheetContent($0) }
                        .preferredColorScheme(user.accessLevel == .boss ? .dark : .none)
                        .environment(\.user, user)
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
            .onAppear {
//                schedules.forEach { modelContext.delete($0) }
//                doctors.forEach { modelContext.delete($0) }
//                patients.forEach { modelContext.delete($0) }
//                pricelistItems.forEach { modelContext.delete($0) }
                
//                let pricelistItems: [PricelistItem] = load("priceList.json")
//                for pricelistItem in pricelistItems {
//                    modelContext.insert(pricelistItem)
//                }
            }
        } else {
            LoginScreen(user: $user)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Coordinator())
        .modelContainer(for: Doctor.self, inMemory: true)
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Environment

private struct UserKey: EnvironmentKey {
    static let defaultValue: User = ExampleData.doctor
}

extension EnvironmentValues {
    var user: User {
        get { self[UserKey.self] }
        set { self[UserKey.self] = newValue }
    }
}
