//
//  MockCKShare.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/23/25.
//

#if DEBUG

import SwiftUI
import CloudKit

struct MockParticipant: Hashable {
    let name: String
    let status: String
    let role: String
    let permission: String
}

struct ParticipantPreviewView: View {
    let participants: [MockParticipant]

    var body: some View {
        Section {
            ForEach(participants.indices, id: \.self) { index in
                let participant = participants[index]
                VStack(alignment: .leading) {
                    Text(participant.name)
                        .font(.headline)
                    Text("Acceptance Status: \(participant.status)")
                        .font(.subheadline)
                    Text("Role: \(participant.role)")
                        .font(.subheadline)
                    Text("Permissions: \(participant.permission)")
                        .font(.subheadline)
                }
                .padding(.bottom, 8)
            }
        } header: {
            Text("Participants")
        }
    }
}

#endif
