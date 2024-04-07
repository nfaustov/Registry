//
//  ActivityView.swift
//  Registry
//
//  Created by Николай Фаустов on 07.04.2024.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
