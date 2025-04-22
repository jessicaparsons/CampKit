//
//  AppDelegate.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import CloudKit
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith metadata: CKShare.Metadata) {
        let op = CKAcceptSharesOperation(shareMetadatas: [metadata])
        op.qualityOfService = .userInitiated
        op.perShareResultBlock = { (metadata: CKShare.Metadata, result: Result<CKShare, Error>) in
            switch result {
            case .success(let share):
                print("✅ Share accepted: \(share.recordID.recordName)")
                NotificationCenter.default.post(name: .didAcceptShare, object: nil)
            case .failure(let error):
                print("Share acceptance failed: \(error)")
            }
        }

        CKContainer(identifier: metadata.containerIdentifier).add(op)
    }
}
