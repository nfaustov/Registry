//
//  SearchBar.swift
//  Registry
//
//  Created by Николай Фаустов on 16.01.2024.
//

import UIKit
import SwiftUI

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isPresented: Bool
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isPresented: Bool

        init(text: Binding<String>, isPresented: Binding<Bool>) {
            _text = text
            _isPresented = isPresented
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.endEditing(true)
            searchBar.setShowsCancelButton(false, animated: true)
            isPresented = false
        }

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
            isPresented = true
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            
        }

        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            if text.isEmpty {
                searchBar.setShowsCancelButton(false, animated: true)
                isPresented = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isPresented: $isPresented)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.backgroundColor = .secondarySystemBackground

        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
