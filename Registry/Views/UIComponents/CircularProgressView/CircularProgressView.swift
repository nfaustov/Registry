//
//  CircularProgressView.swift
//  Registry
//
//  Created by Николай Фаустов on 11.04.2024.
//

import SwiftUI

struct CircularProgressView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.blue)
    }
}

#Preview {
    CircularProgressView()
}
