//
//  DebugLog.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import Foundation

func debugLog(_ message: String) {
#if DEBUG
    print("\(message)")
#else
    if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
        print("[TestFlight] \(message)")
    }
#endif
}
