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
    var showPurchaseAlert: Bool = false
    var purchaseAlertMessage: String = ""
    
    init() {
        updates = observeTransactionUpdates()
        Task {
            await checkPurchasedProducts()
        }
    }
    
    ///Trigger alert for purchases
    func triggerAlert(message: String) {
        purchaseAlertMessage = message
        showPurchaseAlert = true
    }
    
    ///Fetch product from the App Store
    func fetchProducts() async -> Product? {
        do {
            let products = try await Product.products(for: [Constants.productIDPro])
            return products.first
        } catch {
            #if DEBUG
            print("Failed to fetch products: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
    
    ///Purchase Pro
    func purchasePro() async {
        do {
            guard let product = await fetchProducts() else { return }
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if let transaction = try? verification.payloadValue, transaction.revocationDate == nil {
                    
                    await transaction.finish()
                    isProUnlocked = true
                    UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                    triggerAlert(message: "Thank you for purchasing Pro!")
                }
            case .userCancelled:
                #if DEBUG
                print("User cancelled")
                #endif
            default:
                #if DEBUG
                print("Something went wrong with your purchase. Please try again.")
                #endif
                //triggerAlert(message: "Something went wrong with your purchase. Please try again.")
            }
        } catch {
            
        }
    }
    
    ///Check if the user already purchased the product
    func checkPurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Constants.productIDPro {
                
                isProUnlocked = true
                UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                
            }
        }
    }
    
    ///Restore purchases
    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Constants.productIDPro {
                
                isProUnlocked = true
                UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                
            } else {
                
            }
        }
    }
    
    
    ///Observe real-time transaction updates
    private func observeTransactionUpdates() -> Task<Void, Never>? {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result, transaction.productID == Constants.productIDPro {
                    
                    self.isProUnlocked = true
                    UserDefaults.standard.set(true, forKey: Constants.userDefaultsProKey)
                    
                }
            }
        }
    }
}
