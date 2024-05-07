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

    @Query private var doctors: [Doctor]

    // MARK: -

    var body: some View {
        Section {
            DisclosureGroup("Врачи") {
                List(doctors) { doctor in
                    HStack {
                        PersonImageView(person: doctor)
                            .frame(width: 56, height: 56, alignment: .top)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 0) {
                            Text(doctor.id.uuidString)
                                .font(.footnote)
                            Text(doctor.fullName)

                            HStack {
                                Text("Баланс")
                                Text("\(Int(doctor.balance))")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 6)
                                
                        }
                        .padding(.leading)
                    }
                }
            }
        }
    }
}

#Preview {
    DoctorsChart()
}
