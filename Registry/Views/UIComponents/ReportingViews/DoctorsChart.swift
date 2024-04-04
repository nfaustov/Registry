//
//  DoctorsChart.swift
//  Registry
//
//  Created by Николай Фаустов on 01.04.2024.
//

import SwiftUI
import SwiftData

struct DoctorsChart: View {
    // MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Query private var doctors: [Doctor]

    // MARK: - State

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            Text("Врачи")
                .font(.title)
                .padding(.bottom, 20)

            Text("Врачей: \(doctors.count)")
        }
    }
}

#Preview {
    DoctorsChart()
}
