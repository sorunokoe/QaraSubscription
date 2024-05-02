//
//  SwiftUIView.swift
//  
//
//  Created by SALGARA, YESKENDIR on 02.05.24.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

@MainActor
public struct QaraRevenuePaywall: View {
    
    @State var packages: [Package] = []
    
    let entitlementIdentifier: String
    
    public init(entitlementIdentifier: String) {
        self.entitlementIdentifier = entitlementIdentifier
        QaraRevenueCat.shared.configure(apiKey: "appl_mugZXTEAngsSPeaMPubAxBuUKXu", userID: nil)
    }
    
    public var body: some View {
        VStack {
            ForEach(packages, id: \.identifier) {
                Text($0.storeProduct.localizedTitle)
                    .border(.red)
            }
        }
        .presentPaywallIfNeeded(
            requiredEntitlementIdentifier: entitlementIdentifier,
            purchaseCompleted: { customerInfo in
                print("Purchase completed: \(customerInfo.entitlements)")
            },
            restoreCompleted: { customerInfo in
                // Paywall will be dismissed automatically if "pro" is now active.
                print("Purchases restored: \(customerInfo.entitlements)")
            }
        )
        .task {
            packages = await QaraRevenueCat.shared.getOfferings()
            print(packages)
        }
    }
}


#Preview {
    QaraRevenuePaywall(entitlementIdentifier: "pro")
}
