//
//  DoctorView.swift
//  Registry
//
//  Created by Николай Фаустов on 16.01.2024.
//

import SwiftUI

struct DoctorView: View {
    // MARK: - Dependencies

    var doctor: Doctor
    var presentation: Presentation

    // MARK: -
    
    var body: some View {
        if presentation == .gridItem {
            ZStack(alignment: .bottomLeading) {
                PersonImageView(person: doctor)
                    .frame(
                        width: isPhoneUserInterfaceIdiom ? 140 : 200,
                        height: isPhoneUserInterfaceIdiom ? 175 : 250,
                        alignment: .top
                    )
                    .overlay {
                        let gradient = Gradient(colors: [.black.opacity(0.8), .clear])
                        LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .center)
                    }

                VStack(alignment: .leading) {
                    Text(doctor.initials)
                        .font(isPhoneUserInterfaceIdiom ? .subheadline : .headline)
                    Text(doctor.department.specialization)
                        .font(isPhoneUserInterfaceIdiom ? .caption : .subheadline)
                }
                .foregroundColor(.white)
                .padding(isPhoneUserInterfaceIdiom ? 8 : 12)
            }
            .frame(
                width: isPhoneUserInterfaceIdiom ? 140 : 200,
                height: isPhoneUserInterfaceIdiom ? 175 : 250
            )
            .cornerRadius(isPhoneUserInterfaceIdiom ? 8 : 16)
            .padding()
        } else if presentation == .listRow {
            HStack {
                PersonImageView(person: doctor)
                    .frame(
                        width: isPhoneUserInterfaceIdiom ? 52 : 64,
                        height: isPhoneUserInterfaceIdiom ? 52 : 64,
                        alignment: .top
                    )
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(doctor.fullName)
                        .font(.headline)
                        .lineLimit(2)
                    Text(doctor.department.specialization)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    DoctorView(doctor: ExampleData.doctor, presentation: .gridItem)
}

// MARK: - Calculations

private extension DoctorView {
    var isPhoneUserInterfaceIdiom: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

// MARK: - Presentation

extension DoctorView {
    enum Presentation {
        case listRow
        case gridItem
    }
}
