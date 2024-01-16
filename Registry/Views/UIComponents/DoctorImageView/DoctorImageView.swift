//
//  DoctorImageView.swift
//  Registry
//
//  Created by Николай Фаустов on 09.01.2024.
//

import SwiftUI

struct DoctorImageView: View {
    // MARK: - Dependencies

    let doctor: Doctor

    // MARK: -

    var body: some View {
        if let imageData = doctor.image,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Image("female-doctor")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

#Preview {
    DoctorImageView(doctor: ExampleData.doctor)
}
