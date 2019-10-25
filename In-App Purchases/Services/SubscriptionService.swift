//
//  SubscriptionService.swift
//  In-App Purchases
//
//  Created by Igor Medelian on 10/1/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import StoreKit

final class SubscriptionService: NSObject {

    static let shared = SubscriptionService()
    
    private let itcAccountSecret = "fda77d4779be47578b259b80c16ab94c"

    public typealias UploadReceiptCompletion = (_ result: Result<(sessionId: String, currentSubscriptions: [PaidSubscription]), Error>) -> Void

    var hasReceiptData: Bool {
        return loadReceipt() != nil
    }

    var hasSuccessfullyLoadedSubscriptions = false
    var currentSessionId: String?
    var currentSubscriptions: [PaidSubscription] = []

    var subscriptions: [Subscription]? {
        didSet {
            NotificationCenter.default.post(name: .subscriptionsLoaded, object: subscriptions)
        }
    }

    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    func fetchSubscriptions() {
        let productIDs = Set([Products.monthlyGroup1, Products.yearlyGroup1])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }

    func purchase(subscription: Subscription) {
        let payment = SKPayment(product: subscription.product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        guard let receiptData = loadReceipt() else { return }
        upload(receipt: receiptData) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.currentSessionId = result.sessionId
                self.currentSubscriptions = result.currentSubscriptions
                completion?(true)
            case .failure(let error):
                print("Receipt Upload Failed: \(error)")
                completion?(false)
            }
        }
    }

    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }

    /// Trade receipt for session id
    public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": itcAccountSecret
        ]
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])

            let receiptURL = Bundle.main.appStoreReceiptURL
            let appleServer = receiptURL?.lastPathComponent == "sandboxReceipt" ? "sandbox" : "buy"
            let url = URL(string: "https://\(appleServer).itunes.apple.com/verifyReceipt")!

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyData

            let task = URLSession.shared.dataTask(with: request) { (responseData, _, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let responseData = responseData {
                    do {
                        let json = try JSONSerialization.jsonObject(with: responseData, options: []) as! [String: Any]
                        let session = Session(receiptData: data, parsedReceipt: json)
                        let result = (sessionId: session.id, currentSubscriptions: session.currentSubscriptions)
                        completion(.success(result))
                    } catch let error {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()

        } catch let error {
            completion(.failure(error))
        }
    }
}

// MARK: - SKProductsRequestDelegate

extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        hasSuccessfullyLoadedSubscriptions = true
        subscriptions = response.products.map { Subscription(product: $0) }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscriptions Failed Loading: \(error.localizedDescription)")
        }
    }
}
