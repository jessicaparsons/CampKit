//
//  CloudSharingSheet.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/19/25.
//

import SwiftUI
import CloudKit


struct CloudSharingSheet: UIViewControllerRepresentable {
    let controller: UICloudSharingController

    func makeUIViewController(context: Context) -> UICloudSharingController {
        controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
}

