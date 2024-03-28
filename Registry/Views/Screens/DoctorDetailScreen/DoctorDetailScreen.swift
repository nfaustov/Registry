//
//  DoctorDetailScreen.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI

struct DoctorDetailScreen: View {
    // MARK: - Dependencies

    let doctor: Doctor

    // MARK: -

    var body: some View {
        VStack(alignment: .leading) {
            PersonImageView(person: doctor)
                .frame(width: 220, height: 275, alignment: .top)
                .clipShape(.rect(cornerRadius: 16, style: .continuous))

            Text(doctor.fullName)
            DateText(doctor.birthDate, format: .birthDate)
            Text(doctor.phoneNumber)
            Text(doctor.department.specialization)
            DurationLabel(doctor.serviceDuration, systemImage: "clock")
            Text("Кабинет \(doctor.defaultCabinet)")
            Text(doctor.info)
        }
    }
}

#Preview {
    DoctorDetailScreen(doctor: ExampleData.doctor)
        .previewInterfaceOrientation(.landscapeRight)
}
