//
//  iOSCheckBoxToggleStyle.swift
//  Registry
//
//  Created by Николай Фаустов on 09.01.2024.
//

import SwiftUI

struct iOSCheckBoxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "minus.circle.fill" : "circle")
            }
        }
        .tint(configuration.isOn ? .red : .secondary)
    }
}
