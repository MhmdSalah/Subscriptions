//
//  Products.swift
//  In-App Purchases
//
//  Created by Igor Medelian on 10/25/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import Foundation

fileprivate let productIDPrefix = Bundle.main.bundleIdentifier! + "."

struct Products {
    public static let monthlyGroup1 = productIDPrefix + "group1.month"
    public static let yearlyGroup1 = productIDPrefix + "group1.year"
}
