//
//  PricelistView.swift
//  Registry
//
//  Created by Николай Фаустов on 17.01.2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Algorithms

struct PricelistView: View {
    // MARK: - Dependencies

    @Query private var pricelistItems: [PricelistItem]

    private let filterText: String
    private let size: Size

    @Binding var selectedPricelistItem: PricelistItem?
    @Binding var isSearching: Bool

    // MARK: - State

    @State private var selectedCategory: Department = .ultrasound

    // MARK: -

    init(filterText: String, size: Size = .regular, selectedPricelistItem: Binding<PricelistItem?> = .constant(nil), isSearching: Binding<Bool>) {
        self.filterText = filterText
        self.size = size
        self._selectedPricelistItem = selectedPricelistItem
        self._isSearching = isSearching
        _pricelistItems = Query(
            filter: #Predicate {
                if filterText.isEmpty {
                    return !$0.archived
                } else {
                    return !$0.archived && (
                        $0.title.localizedStandardContains(filterText) ||
                        $0.id.localizedStandardContains(filterText)
                    )
                }
            }
        )
    }

    var body: some View {
        List(categories) { category in
            Section {
                ForEach(pricelistItems.filter { $0.category == category }) { item in
                    Button {
                        if size == .regular {
                            selectedPricelistItem = item
                        }
                    } label: {
                        HStack {
                            if size == .regular && UIDevice.current.userInterfaceIdiom == .pad {
                                Text(item.id)
                                    .frame(width: 132, alignment: .leading)

                                Divider()
                                    .padding(.vertical, 4)
                            }

                            Text(item.title)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                
                            Divider()
                                .padding(.vertical, 4)

                            CurrencyText(item.price, unit: false)
                                .frame(width: size == .regular ? 60 : 44, alignment: .leading)
                        }
                        .font(size == .regular ? .body : .footnote)
                        .draggable(item)
                    }
                    .tint(.primary)
                    .listRowBackground(selectedPricelistItem == item ? Color(.systemFill) : .clear)
                }
            } header: {
                if isSearching {
                    Text(category.rawValue)
                        .font(size == .regular ? .title3 : .headline)
                        .fontWeight(.medium)
                } else {
                    Menu {
                        ForEach(Department.allCases.sorted(by: >)) { department in
                            Button(department.rawValue) {
                                withAnimation {
                                    self.selectedCategory = department
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .font(size == .regular ? .title3 : .headline)
                        .fontWeight(.medium)
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .overlay {
            if categories.isEmpty {
                ContentUnavailableView("Поиск услуг", systemImage: "magnifyingglass", description: Text("Введите название или код услуги в поле для поиска"))
            }
        }
    }
}

#Preview {
    PricelistView(filterText: "", selectedPricelistItem: .constant(nil), isSearching: .constant(false))
}

// MARK: - Calculations

private extension PricelistView {
    private var categories: [Department] {
        if filterText.isEmpty {
            return [selectedCategory]
        } else {
            return Array(
                pricelistItems
                    .filter { !$0.archived }
                    .map { $0.category }
                    .uniqued()
            )
        }
    }
}

// MARK: - Size

extension PricelistView {
    enum Size {
        case regular
        case compact
    }
}

// MARK: - Transferable

extension PricelistItem: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .pricelistItem)
    }
}

// MARK: - UTType

extension UTType {
    static let pricelistItem = UTType(exportedAs: "com.yourcompany.pricelistItem")
}
