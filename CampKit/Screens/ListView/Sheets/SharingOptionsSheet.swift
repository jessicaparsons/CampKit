//
//  SharingOptionsSheet.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/19/25.
//

import SwiftUI
import CloudKit

struct SharingOptionsSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
