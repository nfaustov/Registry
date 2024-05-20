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
                    .frame(width: 200, height: 250, alignment: .top)
                    .overlay {
                        if doctor.image != nil {
                            let gradient = Gradient(colors: [.black.opacity(0.8), .clear])
                            LinearGradient(gradient: gradient, startPoint: .bottom, endPoint: .center)
                        }
                    }

                VStack(alignment: .leading) {
                    Text(doctor.initials)
                        .font(.headline)
                    Text(doctor.department.specialization)
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding(12)
            }
            .frame(width: 200, height: 250)
            .cornerRadius(16)
            .padding()
        } else if presentation == .listRow {
            HStack {
                PersonImageView(person: doctor)
                    .frame(width: 64, height: 64, alignment: .top)
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

// MARK: - Presentation

extension DoctorView {
    enum Presentation {
        case listRow
        case gridItem
    }
}
