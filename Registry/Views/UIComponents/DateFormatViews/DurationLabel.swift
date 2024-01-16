//
//  DurationLabel.swift
//  Registry
//
//  Created by Николай Фаустов on 09.01.2024.
//

import SwiftUI

struct DurationLabel: View {
    // MARK: - Dependencies

    private let duration: TimeInterval
    private let systemImage: String

    // MARK: -

    init(_ duration: TimeInterval, systemImage: String) {
        self.duration = duration
        self.systemImage = systemImage
    }

    var body: some View {
        Label(durationString(duration), systemImage: systemImage)
    }
}

#Preview {
    DurationLabel(3000, systemImage: "clock")
}

// MARK: - Calculations

private extension DurationLabel {
    func durationString(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = (Int(duration) % 3600) / 60

        var result = hours > 0 ? "\(hours) ч. " : ""

        if minutes > 0 {
            result += "\(minutes) мин."
        }

        return result
    }
}
