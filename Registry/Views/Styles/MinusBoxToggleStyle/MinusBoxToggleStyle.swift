//
//  MinusBoxToggleStyle.swift
//  Registry
//
//  Created by Николай Фаустов on 09.01.2024.
//

import SwiftUI

struct MinusBoxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "minus.circle.fill" : "circle")
                .tint(configuration.isOn ? .red : .secondary)
        }
    }
}

extension ToggleStyle where Self == MinusBoxToggleStyle {
    static var minusBox: MinusBoxToggleStyle {
        MinusBoxToggleStyle()
    }
}
