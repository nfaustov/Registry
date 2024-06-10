//
//  PromotionsDebugView.swift
//  Registry
//
//  Created by Николай Фаустов on 10.06.2024.
//

import SwiftUI
import SwiftData

struct PromotionsDebugView: View {
    @Query private var promotions: [Promotion]

    @State private var selectedPromotion: Promotion?

    var body: some View {
        List(promotions) { promotion in
            Text("\(promotion.discountRate)")
            Button {
                selectedPromotion = promotion
            } label: {
                LabeledContent(promotion.title) {
                    DateText(promotion.expirationDate, format: .date)
                }
            }
        }
        .sheet(item: $selectedPromotion) { promotion in
            Form {
                ForEach(promotion.pricelistItems) { item in
                    Text(item.title)
                }
            }
        }
    }
}

#Preview {
    PromotionsDebugView()
}
