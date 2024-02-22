//
//  DatePickerDateView.swift
//  Registry
//
//  Created by Николай Фаустов on 16.01.2024.
//

import SwiftUI

struct DatePickerDateView: View {
    // MARK: - Dependencies

    var date: Date

    // MARK: -

    var body: some View {
        if dateStrings.count == 3 {
            HStack {
                Text(dateStrings[0])
                    .fontWeight(.bold)

                ZStack {
                    Rectangle()
                        .frame(width: 32, height: 24)
                        .foregroundColor(Color("black"))
                        .cornerRadius(4)
                    Text(dateStrings[1])
                        .foregroundColor(.white)
                }

                Text(dateStrings[2])
                    .fontWeight(.thin)
            }
        }
    }
}

#Preview {
    DatePickerDateView(date: Date())
}

// MARK: - Calculations

private extension DatePickerDateView {
    var dateStrings: [String] {
        let stringDate = DateFormat.datePickerDate.string(from: date)
        let splitDate = stringDate.split(separator: " ")
        
        return splitDate.map { "\($0)" }
    }
}
