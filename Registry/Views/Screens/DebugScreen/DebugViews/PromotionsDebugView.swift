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

    var body: some View {
        List(promotions) { promotion in
            Text("\(promotion.discountRate)")
            LabeledContent(promotion.title) {
                DateText(promotion.expirationDate, format: .date)
            }
        }
    }
}

#Preview {
    PromotionsDebugView()
}
