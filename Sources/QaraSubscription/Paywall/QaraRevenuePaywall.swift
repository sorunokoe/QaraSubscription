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
    let entitlementIdentifier: String

    var purchaseStarted: (() -> Void)?
    var purchaseCompleted: (() -> Void)?
    var purchaseCancelled: (() -> Void)?
    var restoreCompleted: (() -> Void)?
    var purchaseFailed: (() -> Void)?

    public init(
        entitlementIdentifier: String,
        purchaseStarted: (() -> Void)? = nil,
        purchaseCompleted: (() -> Void)? = nil,
        purchaseCancelled: (() -> Void)? = nil,
        restoreCompleted: (() -> Void)? = nil,
        purchaseFailed: (() -> Void)? = nil
    ) {
        self.entitlementIdentifier = entitlementIdentifier
        self.purchaseStarted = purchaseStarted
        self.purchaseCompleted = purchaseCompleted
        self.purchaseCancelled = purchaseCancelled
        self.restoreCompleted = restoreCompleted
        self.purchaseFailed = purchaseFailed
//        QaraRevenueCat.shared.configure(apiKey: "appl_mugZXTEAngsSPeaMPubAxBuUKXu", userID: nil)
    }

    public var body: some View {
        EmptyView()
            .presentPaywallIfNeeded(
                requiredEntitlementIdentifier: entitlementIdentifier,
                presentationMode: .fullScreen,
                purchaseStarted: {
                    #if DEBUG
                    print("💰Purchase started")
                    #endif
                    purchaseStarted?()
                },
                purchaseCompleted: { customerInfo in
                    #if DEBUG
                    print("💰Purchase completed: \(customerInfo.entitlements)")
                    #endif
                    purchaseCompleted?()
                },
                purchaseCancelled: {
                    #if DEBUG
                    print("💰Purchase canceled")
                    #endif
                    purchaseCancelled?()
                },
                restoreCompleted: { customerInfo in
                    #if DEBUG
                    print("💰Purchases restored: \(customerInfo.entitlements)")
                    #endif
                    restoreCompleted?()
                },
                purchaseFailure: { error in
                    #if DEBUG
                    print("💰Purchase failured: \(error.localizedDescription)")
                    #endif
                    purchaseFailed?()
                }
            )
    }
}

#Preview {
    QaraRevenuePaywall(entitlementIdentifier: "pro")
}
