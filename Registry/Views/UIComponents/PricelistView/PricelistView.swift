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

    var filterText: String
    var size: Size = .regular

    @Binding var selectedPricelistItem: PricelistItem?

    // MARK: -

    init(filterText: String, size: Size = .regular, selectedPricelistItem: Binding<PricelistItem?>) {
        self.filterText = filterText
        self.size = size
        self._selectedPricelistItem = selectedPricelistItem
        _pricelistItems = Query(
            filter: #Predicate {
                if filterText.isEmpty {
                    return true
                } else {
                    return $0.title.localizedStandardContains(filterText) || $0.id.localizedStandardContains(filterText)
                }
            },
            sort: \PricelistItem.category,
            order: .forward
        )
    }

    var body: some View {
        List(categories) { category in
            Section {
                ForEach(pricelistItems) { item in
                    Button {
                        if size == .regular {
                            selectedPricelistItem = item
                        }
                    } label: {
                        HStack {
                            if size == .regular {
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

                            Text(Int(item.price), format: .currency(code: ""))
                                .frame(width: size == .regular ? 60 : 44, alignment: .leading)
                        }
                        .font(size == .regular ? .body : .footnote)
                        .draggable(item)
                    }
                    .tint(.primary)
                    .listRowBackground(selectedPricelistItem == item ? Color(.systemFill) : .clear)
                }
            } header: {
                Text(category.rawValue)
                    .font(size == .regular ? .title3 : .headline)
                    .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    PricelistView(filterText: "", selectedPricelistItem: .constant(nil))
}

// MARK: - Calculations

private extension PricelistView {
    private var categories: [Department] {
        if filterText.isEmpty {
            return Department.allCases
        } else {
            return Array(
                pricelistItems
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
