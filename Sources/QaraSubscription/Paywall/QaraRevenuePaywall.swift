//
//  SwiftUIView.swift
//
//
//  Created by SALGARA, YESKENDIR on 02.05.24.
//

import RevenueCat
import RevenueCatUI
import SwiftUI

@MainActor
public struct QaraRevenuePaywall: View {
    
    let offeringIdentifier: String
    let entitlementIdentifier: String
    
    @State var offering: Offering?

    var purchaseStarted: (() -> Void)?
    var purchaseCompleted: (() -> Void)?
    var purchaseCancelled: (() -> Void)?
    var restoreCompleted: (() -> Void)?
    var purchaseFailed: (() -> Void)?

    @State var showPaywall: Bool = false

    public init(
        offeringIdentifier: String = "Default",
        entitlementIdentifier: String,
        purchaseStarted: (() -> Void)? = nil,
        purchaseCompleted: (() -> Void)? = nil,
        purchaseCancelled: (() -> Void)? = nil,
        restoreCompleted: (() -> Void)? = nil,
        purchaseFailed: (() -> Void)? = nil
    ) {
        self.offeringIdentifier = offeringIdentifier
        self.entitlementIdentifier = entitlementIdentifier
        self.purchaseStarted = purchaseStarted
        self.purchaseCompleted = purchaseCompleted
        self.purchaseCancelled = purchaseCancelled
        self.restoreCompleted = restoreCompleted
        self.purchaseFailed = purchaseFailed
//        QaraRevenueCat.shared.configure(apiKey: "appl_mugZXTEAngsSPeaMPubAxBuUKXu", userID: nil)
    }

    public var body: some View {
        VStack {}
            .task {
                guard Purchases.isConfigured else {
                    #if DEBUG
                    print("💰Purchase error: purchasesNotConfigured")
                    #endif
                    return
                }
                if
                    let info = try? await Purchases.shared.customerInfo(),
                    !info.entitlements
                        .activeInCurrentEnvironment
                        .keys
                        .contains(entitlementIdentifier)
                {
                    Purchases.shared.getOfferings { (offerings, error) in
                        if let offering = offerings?.offering(identifier: offeringIdentifier) {
                            self.offering = offering
                        }
                    }
                }
            }
            .fullScreenCover(item: $offering, content: { offering in
                PaywallView(offering: offering, displayCloseButton: false)
                    .onPurchaseCancelled {
                        #if DEBUG
                        print("💰Purchase canceled")
                        #endif
                        purchaseCancelled?()
                    }
                    .onPurchaseStarted { _ in
                        #if DEBUG
                        print("💰Purchase started")
                        #endif
                        purchaseStarted?()
                    }
                    .onPurchaseCompleted { info in
                        #if DEBUG
                        print("💰Purchase completed: \(info.entitlements)")
                        #endif
                        showPaywall = false
                        purchaseCompleted?()
                    }
                    .onRestoreCompleted { info in
                        #if DEBUG
                        print("💰Purchases restored: \(info.entitlements)")
                        #endif
                        showPaywall = false
                        restoreCompleted?()
                    }
                    .onPurchaseFailure { error in
                        #if DEBUG
                        print("💰Purchase failured: \(error.localizedDescription)")
                        #endif
                        purchaseFailed?()
                    }
            })
    }
}

#Preview {
    QaraRevenuePaywall(entitlementIdentifier: "pro")
}
