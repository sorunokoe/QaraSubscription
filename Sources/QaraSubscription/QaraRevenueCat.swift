//
//  File.swift
//
//
//  Created by SALGARA, YESKENDIR on 30.04.24.
//

import Foundation
import RevenueCat

public class QaraRevenueCat {
    public static var shared = QaraRevenueCat()

    private init() {}

    public func configure(apiKey: String, userID: String?) {
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: apiKey, appUserID: userID)
    }

    public func logIn(userID: String) {
        Purchases.shared.logIn(userID) { customerInfo, _, error in
            #if DEBUG
            print("💰 QaraRevenueCat logIn:")
            if let error {
                print("🔴 " + error.localizedDescription)
            }
            if let customerInfo {
                print("🤑 Active subscriptions:")
                customerInfo.activeSubscriptions.forEach {
                    print("- \($0)")
                }
            }
            #endif
        }
    }

    public func logOut() async {
        _ = try? await Purchases.shared.logOut()
    }

    public func getOfferings() async -> [Package] {
        await withCheckedContinuation { continuation in
            Purchases.shared.getOfferings { offerings, error in
                #if DEBUG
                if let error {
                    print("🔴 " + error.localizedDescription)
                }
                #endif
                if let packages = offerings?.current?.availablePackages {
                    continuation.resume(returning: packages)
                }
            }
        }
    }
}
