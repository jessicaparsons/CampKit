//
//  PersistenceController+Sharing.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import Foundation
import CoreData
import CloudKit

extension PersistenceController {
    
    
    func existingShare(packingList: PackingList) -> CKShare? {
        if let shareSet = try? persistentContainer.fetchShares(matching: [packingList.objectID]),
           let (_, share) = shareSet.first {
            print("Share is: \(share)")
            return share
        }
        return nil
    }
    
    func share(with title: String) -> CKShare? {
        let stores = [privatePersistentStore, sharedPersistentStore]
        let shares = try? persistentContainer.fetchShares(in: stores)
        let share = shares?.first(where: { $0.title == title })
        return share
    }
    
    func shareTitles() -> [String] {
        let stores = [privatePersistentStore, sharedPersistentStore]
        let shares = try? persistentContainer.fetchShares(in: stores)
        return shares?.map { $0.title } ?? []
    }
    
    func isParticipatingShare(with title: String) -> Bool {
        let shares = try? persistentContainer.fetchShares(in: [sharedPersistentStore])
        let share = shares?.first(where: { $0.title == title })
        return share == nil ? false : true
    }
    
    func configure(share: CKShare, with packingList: PackingList? = nil) {
        share[CKShare.SystemFieldKey.title] = "My Packing List"
    }
    
}
