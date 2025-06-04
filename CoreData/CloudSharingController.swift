//
//  CloudSharingController.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import CloudKit
import SwiftUI

struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let list: PackingList
    
    func makeCoordinator() -> CloudSharingCoordinator {
        CloudSharingCoordinator(list: list)
    }
    
    func makeUIViewController(context: Context) -> UICloudSharingController {
        // 1
        share[CKShare.SystemFieldKey.title] = list.title
        // 2
        let controller = UICloudSharingController(share: share, container: container)
        controller.modalPresentationStyle = .formSheet
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
    }
}

final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
    let stack = CoreDataStack.shared
    let list: PackingList
    init(list: PackingList) {
        self.list = list
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        list.title
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Failed to save share: \(error)")
    }
    
    ///Update CloudKit with changes made to share such as title, permissions, participants
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Share was saved by user")
        
        guard let share = csc.share else { return }
        
        stack.persistentContainer.persistUpdatedShare(share, in: stack.sharedPersistentStore)
        
        print("Persisted updated share successfully")
        
        
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        
        Task {
            if stack.isOwner(object: list), let share = csc.share {
                do {
                    
                    await MainActor.run {
                        let viewContext = stack.context
                        
                        // Create a new object in the private store
                        let privateStore = stack.privatePersistentStore
                        
                        // Create a new PackingList in the private store
                        // Copy relevant properties from shared list
                        
                        let privatePackingList = PackingList(
                            context: viewContext,
                            title: list.title,
                            position: Int(list.position),
                            locationName: list.locationName,
                            locationAddress: list.locationAddress,
                            latitude: list.latitude,
                            longitude: list.longitude,
                            elevation: list.elevation,
                            startDate: list.startDate,
                            endDate: list.endDate
                        )
                        
                        privatePackingList.photo = list.photo
                        
                        // Duplicate categories and items
                        for category in list.sortedCategories {
                            let newCategory = Category(
                                context: viewContext,
                                id: UUID(),
                                name: category.name,
                                position: category.position
                            )
                            
                            for item in category.sortedItems {
                                let newItem = Item(
                                    context: viewContext,
                                    title: item.title ?? "Packing Item",
                                    isPacked: item.isPacked)
                                newItem.position = item.position
                                
                                newCategory.addToItems(newItem)
                            }
                            
                            privatePackingList.addToCategories(newCategory)
                        }
                        
                        viewContext.assign(privatePackingList, to: privateStore)
                        
                        // Delete the shared version
                        viewContext.delete(list)
                        
                        do {
                            try viewContext.save()
                            print(" Moved list from shared to private store")
                        } catch {
                            print(" Failed to save after moving list: \(error)")
                        }
                    }
                    
                    //Delete the CKShare from the private CloudKit database
                    
                    let database = CKContainer.default().privateCloudDatabase
                    
                    let (_, deleted) = try await database.modifyRecords(saving: [], deleting: [share.recordID])
                    
                    print("CK Share: \(deleted) is deleted, list will disappear for other participants")
                    
                    
                    
                } catch {
                    print("Failed to delete CKShare: \(error)")
                }
                
            } else {
                print("Participant stopped sharing - no local deletion needed")
            }
        }
        
    }
}


