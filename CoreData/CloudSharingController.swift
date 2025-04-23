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

  func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
    print("Saved the share")
  }

  func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
  }
}
