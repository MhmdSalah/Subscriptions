//
//  Session.swift
//  In-App Purchases
//
//  Created by Igor Medelian on 10/1/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import Foundation

public struct Session {
    public let id: String
    public var paidSubscriptions: [PaidSubscription]

    public var currentSubscriptions: [PaidSubscription] {
        let activeSubscriptions = paidSubscriptions.filter { $0.isActive }
        return activeSubscriptions.sorted { $0.purchaseDate > $1.purchaseDate }
    }

    public var receiptData: Data
    public var parsedReceipt: [String: Any]

    init(receiptData: Data, parsedReceipt: [String: Any]) {
        id = UUID().uuidString
        self.receiptData = receiptData
        self.parsedReceipt = parsedReceipt

        if let receipt = parsedReceipt["receipt"] as? [String: Any], let purchases = receipt["in_app"] as? [[String: Any]] {
            var subscriptions = [PaidSubscription]()
            for purchase in purchases {
                if let paidSubscription = PaidSubscription(json: purchase) {
                    subscriptions.append(paidSubscription)
                }
            }

            paidSubscriptions = subscriptions
        } else {
            paidSubscriptions = []
        }
    }
}

// MARK: - Equatable
extension Session: Equatable {
    public static func ==(lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
}
