//
//  PersonImageView.swift
//  Registry
//
//  Created by Николай Фаустов on 09.01.2024.
//

import SwiftUI

struct PersonImageView: View {
    // MARK: - Dependencies

    let person: Person

    // MARK: -

    var body: some View {
        if let imageData = person.image,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    PersonImageView(person: ExampleData.doctor)
}
