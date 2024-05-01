import StoreKit

public enum StoreError: Error {
    case failedVerification
}

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public final class QaraSubscription: NSObject, ObservableObject {

    enum AppSubscriptionState {
        case active, inactive, none
    }

    static let shared = QaraSubscription()
    private var state: AppSubscriptionState = .none

    @Published var products: [Product] = []
    @Published var transactionState: Product.PurchaseResult?

    var updateListenerTask: Task<Void, Error>?

    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published var subscriptionStatus: AppSubscriptionState = .none

    private override init() { 
        super.init()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }

    func configure(secret: String, productsId: [String]) {
        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task {
            // During store initialization, request products from the App Store.
            await fetchProducts(with: productsId)
        }
    }

    @MainActor
    func redeemCode() {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.presentCodeRedemptionSheet()
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    print("🔴 Transaction failed verification")
                }
            }
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []

        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if let subscription = products.first(where: { $0.id == transaction.productID }) {
                    purchasedSubscriptions.append(subscription)
                }
            } catch {
                print("🔴 Some errors with verification")
            }
        }

        self.purchasedSubscriptions = purchasedSubscriptions
        var subscriptionStatus: AppSubscriptionState = .inactive
        for product in products {
            if let subscriptionInfo = product.subscription {
                let status = try? await Product.SubscriptionInfo.status(for: subscriptionInfo.subscriptionGroupID)
                if let state = status?.first?.state {
                    if state == .subscribed || state == .inBillingRetryPeriod || state == .inGracePeriod {
                        subscriptionStatus = .active
                    }
                }
            }
        }
        self.subscriptionStatus = subscriptionStatus
    }

    @MainActor
    func fetchProducts(with productsId: [String]) async {
        do {
            let storeProducts = try await Product.products(for: Set(productsId))
            products = storeProducts
        } catch {
            print("Failed product request from the App Store server: \(error)")
        }
    }

    func purchase(product: Product) async throws -> Transaction? {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            print("✅ Subscription: Purchased..")
            let transaction = try checkVerified(verification)
            await updateCustomerProductStatus()
            await transaction.finish()
            return transaction
        case .userCancelled:
            print("❌ Subscription: Cancelled..")
            return nil
        case .pending:
            print("⏱️ Subscription: Pending..")
            return nil
        default:
            return nil
        }
    }

    func isPurchased(_ product: Product) async throws -> Bool {
        return purchasedSubscriptions.contains(product)
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
}
