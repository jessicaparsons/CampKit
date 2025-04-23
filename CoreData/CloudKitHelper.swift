//
//  CloudKitHelper.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import Foundation
import CloudKit
import CoreTransferable

extension CKShare.ParticipantAcceptanceStatus {
    var stringValue: String {
        return ["Unknown", "Pending", "Accepted", "Removed"][rawValue]
    }
}

extension CKShare {
    var title: String {
        guard let date = creationDate else {
            return "\(UUID().uuidString)"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

extension CKShare: @retroactive Transferable {
    static public var transferRepresentation: some TransferRepresentation {
        
        let ckContainer = MainActor.assumeIsolated {
            PersistenceController.shared.cloudKitContainer
        }

        return CKShareTransferRepresentation { shareToExport in
            .existing(shareToExport, container: ckContainer)
        }
    }
}
