//
//  Subscription.swift
//  In-App Purchases
//
//  Created by Igor Medelian on 10/1/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import StoreKit

struct Subscription {
    let product: SKProduct
    let formattedPrice: String

    init(product: SKProduct) {
        self.product = product

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .behavior10_4
        
        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }

        formattedPrice = formatter.string(from: product.price) ?? "\(product.price)"
    }
}
