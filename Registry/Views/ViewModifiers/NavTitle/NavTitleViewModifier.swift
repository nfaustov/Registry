//
//  NavTitleViewModifier.swift
//  Registry
//
//  Created by Николай Фаустов on 06.01.2024.
//

import SwiftUI

struct NavTitleViewModifier: ViewModifier {
    var title: String
    var subtitle: String?

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        if let subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
    }
}

extension View {
    func navTitle(title: String, subTitle: String? = nil) -> some View {
        modifier(NavTitleViewModifier(title: title, subtitle: subTitle))
    }
}
