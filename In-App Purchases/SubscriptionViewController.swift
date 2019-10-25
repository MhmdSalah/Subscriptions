//
//  SubscriptionViewController.swift
//  In-App Purchases
//
//  Created by Igor Medelian on 10/1/19.
//  Copyright © 2019 imedelyan. All rights reserved.
//

import UIKit

class SubscriptionViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var monthPriceLabel: UILabel!
    @IBOutlet private weak var yearPriceLabel: UILabel!

    // MARK: - Dependencies
    var onPurchaseSuccessfull: ((String) -> Void)?

    // MARK: - Variables
    private var monthFormattedPrice: String? { didSet { monthPriceLabel.text = "Then \(monthFormattedPrice ?? "") per month." } }
    private var yearFormattedPrice: String? { didSet { yearPriceLabel.text = "Then \(yearFormattedPrice ?? "") per year." } }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSubscriptionsLoaded),
                                               name: .subscriptionsLoaded,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfull),
                                               name: .purchaseSuccessful,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        monthFormattedPrice = SubscriptionService.shared.subscriptions?.filter({ $0.product.productIdentifier == Products.monthlyGroup1 }).first?.formattedPrice
        yearFormattedPrice = SubscriptionService.shared.subscriptions?.filter({ $0.product.productIdentifier == Products.yearlyGroup1 }).first?.formattedPrice
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleSubscriptionsLoaded() {
        monthFormattedPrice = SubscriptionService.shared.subscriptions?.filter({ $0.product.productIdentifier == Products.monthlyGroup1 }).first?.formattedPrice
        yearFormattedPrice = SubscriptionService.shared.subscriptions?.filter({ $0.product.productIdentifier == Products.yearlyGroup1 }).first?.formattedPrice
    }

    @objc func handlePurchaseSuccessfull() {
        guard let paidProductId = SubscriptionService.shared.currentSubscriptions.first?.productId else { return }
        dismiss(animated: true) { [weak self] in
            self?.onPurchaseSuccessfull?(paidProductId)
        }
    }
    
    @objc private func handleRestoreSuccessful(notification: Notification) {
        dismiss(animated: true) {
            // merge suscriptions if needed
        }
    }

    @objc private func handleRestoreFailed(notification: Notification) {
        dismiss(animated: true)
    }
    
    // MARK: - IBAction
    @IBAction private func subscribeMonthlyButtonAction(_ sender: Any) {
        guard SubscriptionService.shared.canMakePurchases() else {
            showPurchasesDisabledAlert()
            return
        }
        guard let subscription = SubscriptionService.shared.subscriptions?.filter({ $0.product.productIdentifier == Products.monthlyGroup1 }).first else { return }
        SubscriptionService.shared.purchase(subscription: subscription)
    }

    @IBAction private func subscribeYearlyButtonAction(_ sender: Any) {
        guard SubscriptionService.shared.canMakePurchases() else {
            showPurchasesDisabledAlert()
            return
        }
        guard let subscription = SubscriptionService.shared.subscriptions?.filter({ $0.product.productIdentifier == Products.yearlyGroup1 }).first else { return }
        SubscriptionService.shared.purchase(subscription: subscription)
    }
    
    @IBAction private func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func restoreButtonAction(_ sender: Any) {
        SubscriptionService.shared.restorePurchases()
        showRestoreInProgressAlert()
    }

    // MARK: - Alerts
    private func showPurchasesDisabledAlert() {
        let alert = UIAlertController(title: "Subscription Issue",
                                      message: "Purchases are disabled in your device!",
                                      preferredStyle: .alert)
        let backAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(backAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showRestoreInProgressAlert() {
        let restoreAlert = UIAlertController(title: "Restoring Purchase",
                                             message: "Your purchase history is being restored. Upon completion this dialog will close and you will be sent back to Home screen where you can then add child device with restored subscription.",
                                             preferredStyle: .alert)
        present(restoreAlert, animated: true, completion: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRestoreSuccessful(notification:)),
                                               name: .restoreSuccessful,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRestoreFailed(notification:)),
                                               name: .restoreFailed,
                                               object: nil)
    }
}
