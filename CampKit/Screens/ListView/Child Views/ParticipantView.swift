//
//  ParticipantView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/22/25.
//

import SwiftUI
import CoreData
import CloudKit


struct ParticipantView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let share: CKShare?
    
    var body: some View {
        
        Section {
          if let share = share {
            ForEach(share.participants, id: \.self) { participant in
              VStack(alignment: .leading) {
                Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
                  .font(.headline)
                Text("Acceptance Status: \(string(for: participant.acceptanceStatus))")
                  .font(.subheadline)
                Text("Role: \(string(for: participant.role))")
                  .font(.subheadline)
                Text("Permissions: \(string(for: participant.permission))")
                  .font(.subheadline)
              }
              .padding(.bottom, 8)
            }
          }
        } header: {
          Text("Participants")
        }
        
    }//:BODY
        
}

// MARK: Returns CKShare participant permission
extension ParticipantView {
  private func string(for permission: CKShare.ParticipantPermission) -> String {
    switch permission {
    case .unknown:
      return "Unknown"
    case .none:
      return "None"
    case .readOnly:
      return "Read-Only"
    case .readWrite:
      return "Read-Write"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Permission")
    }
  }

  private func string(for role: CKShare.ParticipantRole) -> String {
    switch role {
    case .owner:
      return "Owner"
    case .privateUser:
      return "Private User"
    case .publicUser:
      return "Public User"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Role")
    }
  }

  private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
    switch acceptanceStatus {
    case .accepted:
      return "Accepted"
    case .removed:
      return "Removed"
    case .pending:
      return "Invited"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
    }
  }
}


//#Preview {
//    ParticipantView()
//}
