//
//  SubscriptionService.swift
//  HydraTrack
//
//  Created by GH on 25/9/2025.
//

import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()
    
    @Published var isSubscribed: Bool = false
    @Published var subscriptionStatus: Product.SubscriptionInfo.Status?
    @Published var products: [Product] = []
    @Published var isLoadingProducts: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var updateListenerTask: Task<Void, Error>?
    
    // Product IDs
    private let monthlyProductID = "com.HydraTrack.premium.monthly"
    private let lifetimeProductID = "com.HydraTrack.premium.lifetime"
    
    init() {
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoadingProducts = true
        
        do {
            let storeProducts = try await Product.products(for: [monthlyProductID, lifetimeProductID])
            self.products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            showAlert(message: "Failed to load products: \(error.localizedDescription)")
        }
        
        isLoadingProducts = false
    }
    
    // MARK: - Purchase Management
    
    func purchase(_ product: Product) async {
        isPurchasing = true
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try await checkVerified(verification)
                
                // For consumables or non-renewing purchases
                await transaction.finish()
                
                // Update subscription status
                await updateSubscriptionStatus()
                
                // Track purchase
                AnalyticsService.shared.trackRevenue(
                    amount: NSDecimalNumber(decimal: product.price).doubleValue,
                    currency: "USD", // StoreKit 2 price doesn't directly expose currency
                    productId: product.id
                )
                
            case .userCancelled:
                // User cancelled, do nothing
                break
                
            case .pending:
                showAlert(message: "Payment is pending. Please check your payment method.")
                
            @unknown default:
                fatalError("Unknown purchase result")
            }
            
        } catch {
            showAlert(message: "Purchase failed: \(error.localizedDescription)")
        }
        
        isPurchasing = false
    }
    
    // MARK: - Subscription Status
    
    func updateSubscriptionStatus() async {
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try await checkVerified(result)
                
                if transaction.productType == .autoRenewable {
                    let status = await transaction.subscriptionStatus
                    await MainActor.run {
                        self.isSubscribed = true
                        self.subscriptionStatus = status
                    }
                    return
                } else if transaction.productType == .nonRenewable {
                    // Check if lifetime purchase is within validity period
                    await MainActor.run {
                        self.isSubscribed = true
                    }
                    return
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        // No active subscription found
        await MainActor.run {
            self.isSubscribed = false
            self.subscriptionStatus = nil
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            showAlert(message: "Purchases restored successfully!")
        } catch {
            showAlert(message: "Failed to restore purchases: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    if transaction.revocationDate == nil {
                        await self.updateSubscriptionStatus()
                    } else {
                        // Subscription was revoked
                        await MainActor.run {
                            self.isSubscribed = false
                            self.subscriptionStatus = nil
                        }
                    }
                    
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkVerified<T>(_ result: VerificationResult<T>) async throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func showAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
    
    // Check if a feature is available
    func isFeatureAvailable(_ feature: PremiumFeature) -> Bool {
        guard !isSubscribed else { return true }
        
        switch feature {
        case .basicTracking:
            return true
        case .advancedAnalytics, .smartInsights, .achievements, .dataExport, .unlimitedHistory, .advancedReminders:
            return false
        }
    }
    
    // Check if user is eligible for free trial
    var isEligibleForFreeTrial: Bool {
        // In a real implementation, you would check if the user has previously used a trial
        // For now, we'll assume all new users are eligible
        return !isSubscribed
    }
    
    // Get the localized trial period text
    func getTrialPeriodText(for product: Product) -> String {
        if product.type == .autoRenewable && isEligibleForFreeTrial {
            return "7-day free trial"
        }
        return ""
    }
}

enum PremiumFeature {
    case basicTracking
    case advancedAnalytics
    case smartInsights
    case achievements
    case dataExport
    case unlimitedHistory
    case advancedReminders
}

enum StoreError: Error {
    case failedVerification
}