//
//  CloudSharingSheet.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/19/25.
//

import SwiftUI
import CloudKit

struct CloudSharingSheet: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        controller.availablePermissions = [.allowReadWrite, .allowReadOnly]
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
}
