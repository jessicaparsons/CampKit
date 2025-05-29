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
    @State private var participants: [CKShare.Participant] = []
    
    var mockParticipants: [MockParticipant]? = nil
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.colorWhite.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                    
                    if share != nil {
                        ForEach(participants, id: \.self) { participant in
                            
                            let nameComponents = participant.userIdentity.nameComponents
                            let formattedName = nameComponents?.formatted(.name(style: .long)) ?? ""
                            let name = formattedName.isEmpty ? (participant.role == .owner ? "You" : "Unknown") : formattedName
                            
                            ParticipantCard(
                                name: name,
                                status: string(for: participant.acceptanceStatus),
                                role: string(for: participant.role),
                                permission: string(for: participant.permission)
                            )
                        }
                        
                    } else if let mockParticipants {
                            ForEach(mockParticipants, id: \.self) { participant in
                                ParticipantCard(
                                    name: participant.name,
                                    status: participant.status,
                                    role: participant.role,
                                    permission: participant.permission
                                )
                            }
                        }
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, Constants.largePadding)
            }//:ZSTACK
            .task {
                if let share = share {
                    participants = share.participants
                }
            }
        }//:NAVIGATIONSTACK
    }

        
}

struct ParticipantCard: View {
    let name: String
    let status: String
    let role: String
    let permission: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            
            VStack(alignment: .leading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color.colorSage)
                        .frame(width: 40, height: 40)
                    Text(name.first.map { String($0) } ?? "")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }//:VSTACK
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.colorSecondaryTitle)
                Group {
                    Text("Status: ")
                        .fontWeight(.medium)
                    +
                    Text("\(status)")
                    Text("Role: ")
                        .fontWeight(.medium)
                    +
                    Text("\(role)")
                    Text("Permissions: ")
                        .fontWeight(.medium)
                    +
                    Text("\(permission)")
                }
                .foregroundStyle(Color.colorTertiaryTitle)
                .font(.subheadline)
            }
            
        }//:HSTACK
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.colorLightestGrey)
        .cornerRadius(Constants.cornerRadius)
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
