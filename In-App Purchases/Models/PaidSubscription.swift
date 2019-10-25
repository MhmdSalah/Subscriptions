//
//  PaidSubscription.swift
//  In-App Purchases
//
//  Created by Igor Medelian on 10/1/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import Foundation

public struct PaidSubscription {

    public enum Level {
        case group1Month
        case group1Year

        init(productId: String) {
            if productId == Products.monthlyGroup1 {
                self = .group1Month
            } else {
                self = .group1Year
            }
        }
    }

    public let productId: String
    public let purchaseDate: Date
    public let expiresDate: Date
    public let level: Level

    public var isActive: Bool {
        // is current date between purchaseDate and expiresDate?
        return (purchaseDate...expiresDate).contains(Date())
    }

    init?(json: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        guard
            let productId = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = dateFormatter.date(from: purchaseDateString),
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = dateFormatter.date(from: expiresDateString)
            else {
                return nil
        }

        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
        self.level = Level(productId: productId)
    }
}
