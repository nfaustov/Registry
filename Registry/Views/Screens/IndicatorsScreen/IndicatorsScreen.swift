//
//  IndicatorsScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 19.03.2024.
//

import SwiftUI
import SwiftData

struct IndicatorsScreen: View {
    // MARK: -

    @Query private var doctors: [Doctor]

    var body: some View {
        Form {
            CashboxReportingView()
            PatientsChart()

//            List(doctors) { doctor in
//                HStack {
//                    PersonImageView(person: doctor)
//                        .frame(width: 80, height: 80, alignment: .top)
//                        .clipShape(Circle())
//
//                    VStack(alignment: .leading) {
//                        Text(doctor.id.uuidString)
//                            .font(.footnote)
//                        Text(doctor.fullName)
//                        LabeledContent("Баланс", value: "\(Int(doctor.balance))")
//                            .frame(width: 160)
//                        LabeledContent("Агентские", value: "\(Int(doctor.agentFee))")
//                            .frame(width: 160)
//                    }
//                    .padding(.leading)
//                }
//            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    IndicatorsScreen()
}
