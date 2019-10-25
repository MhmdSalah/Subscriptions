//
//  Notification+Extensions.swift
//  In-App Purchases
//
//  Created by Igor Medelian on 10/1/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let subscriptionsLoaded = Notification.Name("SubscriptionServiceSubscriptionsLoadedNotification")
    static let restoreSuccessful = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let restoreFailed = Notification.Name("SubscriptionServiceRestoreFailedNotification")
    static let purchaseSuccessful = Notification.Name("SubscriptionServicePurchaseSuccessfulNotification")
}
