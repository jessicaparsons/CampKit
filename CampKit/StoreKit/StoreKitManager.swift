//
//  StoreKitManager.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/19/25.
//

import SwiftUI
import StoreKit

@Observable
@MainActor
class StoreKitManager {
    
    var isProUnlocked: Bool = false
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
        Task {
            await checkPurchasedProducts()
        }
    }
    
    //Fetch product from the App Store
    func fetchProducts() async -> Product? {
        do {
            let products = try await Product.products(for: [Constants.productIDPro])
            return products.first
        } catch {
            print("Failed to fetch products: \(error.localizedDescription)")
            return nil
        }
    }
    
    //Purchase Unlimited Lists
    func purchaseUnlimitedLists() async {
        do {
            guard let product = await fetchProducts() else { return }
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if let transaction = try? verification.payloadValue, transaction.revocationDate == nil {
                    
                    await transaction.finish()
                    isProUnlocked = true
                    UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                    print("Purchase successful!")
                }
            case .userCancelled:
                print("Purchase cancelled by user")
                
            default:
                print("Purchase failed")
            }
        } catch {
            print("Error purchasing product: \(error.localizedDescription)")
        }
    }
    
    //Check if the user already purchased the product
    func checkPurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Constants.productIDPro {
                
                isProUnlocked = true
                UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                print("Already purchased")
            }
        }
    }
    
    //Restore purchases
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Constants.productIDPro {
                
                isProUnlocked = true
                UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                print("Restored purchase")
            } else {
                print("Failed to restore purchase")
            }
        }
    }
    
    
    //Observe real-time transaction updates
    private func observeTransactionUpdates() -> Task<Void, Never>? {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result, transaction.productID == Constants.productIDPro {
                    
                    self.isProUnlocked = true
                    UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                    print("Verified purchase")
                }
            }
        }
    }
}
