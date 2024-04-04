//
//  SchedulesChart.swift
//  Registry
//
//  Created by Николай Фаустов on 01.04.2024.
//

import SwiftUI
import SwiftData

struct SchedulesChart: View {
    //MARK: - Dependencies

    @Environment(\.modelContext) private var modelContext

    @Query private var schedules: [DoctorSchedule]

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            Text("Расписания врачей")
                .font(.title)
                .padding(.bottom, 20)

            Text("Расписаний: \(schedules.count)")
        }
    }
}

#Preview {
    SchedulesChart()
}
