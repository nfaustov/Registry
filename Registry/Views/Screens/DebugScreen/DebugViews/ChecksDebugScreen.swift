//
//  ChecksDebugScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 26.05.2024.
//

import SwiftUI
import SwiftData

struct ChecksDebugScreen: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var checks: [Check] = []

    // MARK: -

    var body: some View {
        List(checks) { check in
            Section {
                if let appointments = check.appointments?.filter({ Calendar.current.isDateInToday($0.scheduledTime) }) {
                    ForEach(appointments.sorted(by: { $0.scheduledTime > $1.scheduledTime })) { appointment in
                        if let patient = appointment.patient {
                            Text(patient.initials)
                        }
                        ForEach(check.services) { service in
                            Text(service.pricelistItem.title)
                        }
                    }
                }
            }
        }
        .onAppear {
            let descriptor = FetchDescriptor<Check>()

            if let todayChecks = try? modelContext.fetch(descriptor) {
                checks = todayChecks
            }
        }
    }
}

#Preview {
    ChecksDebugScreen()
}
