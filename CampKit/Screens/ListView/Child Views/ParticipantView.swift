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
    
    var mockParticipants: [MockParticipant]? = nil
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.colorTan.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                    
                        if let share = share {
                            ForEach(share.participants, id: \.self) { p in
                                participantCard(
                                    name: p.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "Unknown",
                                    status: string(for: p.acceptanceStatus),
                                    role: string(for: p.role),
                                    permission: string(for: p.permission)
                                )
                            }
                        } else if let mockParticipants {
                            ForEach(mockParticipants, id: \.self) { p in
                                participantCard(
                                    name: p.name,
                                    status: p.status,
                                    role: p.role,
                                    permission: p.permission
                                )
                            }
                        }
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, Constants.emptyContentSpacing)
            }
        }//:ZSTACK
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
    }//:NAVIGATIONSTACK

        @ViewBuilder
        private func participantCard(name: String, status: String, role: String, permission: String) -> some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.headline)
                Text("Acceptance Status: \(status)").font(.subheadline)
                Text("Role: \(role)").font(.subheadline)
                Text("Permissions: \(permission)").font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(Constants.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
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


#Preview("Styled ParticipantView with Mock Data") {
   
    NavigationStack {
        ParticipantView(
            share: nil,
            mockParticipants: [
                MockParticipant(name: "Jess Parsons", status: "Accepted", role: "Private User", permission: "Read-Write"),
                MockParticipant(name: "Taylor Swift", status: "Invited", role: "Owner", permission: "Read-Only")
            ]
        )
    }
}
