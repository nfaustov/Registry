//
//  PhotosPickerViewModel.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotosPickerViewModel: ObservableObject {
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }

    private(set) var imageData: Data? = nil

    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection = selection else { return }

        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    selectedImage = image
                    imageData = data
                    return
                }
            }
        }
    }
}
