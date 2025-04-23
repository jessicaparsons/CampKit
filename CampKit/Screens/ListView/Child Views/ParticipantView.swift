////
////  ParticipantView.swift
////  CampKit
////
////  Created by Jessica Parsons on 4/22/25.
////
//
//import SwiftUI
//import CoreData
//import CloudKit
//
///**
// Managing a participant only makes sense when the share exists.
// A private share is a share with the .none public permission.
// A public share is a share with a more-permissive public permission. Any person who has the share link can
// self-add themselves to a public share.
// */
//struct ParticipantView: View {
//    
//    @Environment(\.dismiss) private var dismiss
//    
//    private let share: CKShare
//
//    @State private var toggleProgress: Bool = false
//    @State private var participants = [Participant]()
//    @State private var wasShareDeleted = false
//    
//    private let canUpdateParticipants: Bool
//    private var persistentStoreForShare: NSPersistentStore?
//
//    init(share: CKShare) {
//        self.share = share
//        let privateStore = PersistenceController.shared.privatePersistentStore
//        persistentStoreForShare = PersistenceController.shared.persistentStoreForShare(share)
//        canUpdateParticipants = (persistentStoreForShare == privateStore)
//    }
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if wasShareDeleted {
//                    Text("The share was deleted remotely.").padding()
//                    Spacer()
//                } else {
//                    participantListView()
//                }
//            }
//            .toolbar { toolbarItems() }
//            .listStyle(.inset)
//            .navigationTitle("Participant")
//        }
//        .onAppear {
//            participants = share.participants.filter { $0.role != .owner }.map { Participant($0) }
//        }
//        .onReceive(NotificationCenter.default.storeDidChangePublisher) { notification in
//            processStoreChangeNotification(notification)
//        }
//    }
//    
//    @ViewBuilder
//    private func participantListView() -> some View {
//        ZStack {
//            
//            List {
//                Section(header: sectionHeader()) {
//                    sectionContent()
//                }
//            }
//            
//            if toggleProgress {
//                ProgressView()
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func sectionHeader() -> some View {
//        if canUpdateParticipants {
//            ParticipantListHeader(toggleProgress: $toggleProgress,
//                                  participants: $participants, share: share)
//        }
//    }
//    
//    @ViewBuilder
//    private func sectionContent() -> some View {
//        ForEach(participants, id: \.self) { participant in
//            HStack {
//                VStack {
//                    Text(participant.ckShareParticipant.userIdentity.nameComponents?.formatted() ?? "(No name)")
//                    Text(participant.ckShareParticipant.userIdentity.lookupInfo?.emailAddress ?? "(No email)")
//                }
//                Spacer()
//                Text(participant.ckShareParticipant.acceptanceStatus.stringValue)
//            }
//        }
//        .onDelete(perform: canUpdateParticipants ? deleteParticipant : nil)
//        .emptyListPrompt(participants.isEmpty, prompt: "No participant.")
//    }
//    
//    @ToolbarContentBuilder
//    private func toolbarItems() -> some ToolbarContent {
//        let slashSharingTitle = canUpdateParticipants ? "Stop Sharing" : "Remove Me"
//        ToolbarItem(placement: .cancellationAction) {
//            Button("Dismiss") {
//                dismiss()
//            }
//        }
//        
//        ToolbarItem(placement: .primaryAction) {
//            Button(action: {
//                purgeShare(share, in: persistentStoreForShare)
//            }) {
//                Label(slashSharingTitle, systemImage: "person.2.slash")
//                    .foregroundColor(.red)
//            }
//        }
//        ToolbarItem(placement: .secondaryAction) {
//            ShareLink(item: share.url!.description, subject: Text("Cloud sharing"), message: Text("A cool photo!")) {
//                Label("Share the URL", systemImage: "square.and.arrow.up")
//            }
//        }
//    }
//    
//    private func purgeShare(_ share: CKShare, in persistentStore: NSPersistentStore?) {
//        toggleProgress.toggle()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            PersistenceController.shared.purgeObjectsAndRecords(with: share.recordID, in: persistentStore)
//            toggleProgress.toggle()
//            dismiss()
//        }
//    }
//    
//    private func deleteParticipant(offsets: IndexSet) {
//        withAnimation {
//            let ckShareParticipants = offsets.map { participants[$0].ckShareParticipant }
//            PersistenceController.shared.deleteParticipant(ckShareParticipants, share: share) { share, error in
//                if error == nil, let updatedShare = share {
//                    participants = updatedShare.participants.filter { $0.role != .owner }.map { Participant($0) }
//                }
//            }
//        }
//    }
//    
//    /**
//     Ignore the notification in the following cases:
//     - The notification isn't relevant to the private database.
//     - The notification transaction isn't empty. When a share changes, Core Data triggers a store remote change notification with no transaction.
//     In that case, grab the share with the same title, and use it to update the UI.
//     */
//    private func processStoreChangeNotification(_ notification: Notification) {
//        guard let storeUUID = notification.userInfo?[UserInfoKey.storeUUID] as? String,
//              storeUUID == PersistenceController.shared.privatePersistentStore.identifier else {
//            return
//        }
//        guard let transactions = notification.userInfo?[UserInfoKey.transactions] as? [NSPersistentHistoryTransaction],
//              transactions.isEmpty else {
//            return
//        }
//        if let updatedShare = PersistenceController.shared.share(with: share.title) {
//            participants = updatedShare.participants.filter { $0.role != .owner }.map { Participant($0) }
//            
//        } else {
//            wasShareDeleted = true
//        }
//    }
//}
//
//private struct ParticipantListHeader: View {
//    @Binding var toggleProgress: Bool
//    @Binding var participants: [Participant]
//    var share: CKShare
//    @State private var emailAddress: String = ""
//    @State private var isValidInput = false
//
//    var body: some View {
//        HStack {
//            TextField("Email", text: $emailAddress)
//                .foregroundColor(isValidInput ? .primary : .secondary)
//                .onChange(of: emailAddress) {
//                    isValidInput = isValidEmail
//                }
//            Button {
//                addParticipant()
//            } label: {
//                Label("Add", systemImage: "plus.circle")
//            }
//            .disabled(emailAddress.isEmpty || !isValidInput)
//        }
//    }
//    
//    /**
//     If the participant already exists, there's no need to do anything.
//     */
//    private func addParticipant() {
//        let isExistingParticipant = share.participants.contains {
//            $0.userIdentity.lookupInfo?.emailAddress == emailAddress
//        }
//        if isExistingParticipant {
//            return
//        }
//        
//        toggleProgress.toggle()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            PersistenceController.shared.addParticipant(emailAddress: emailAddress, share: share) { share, error in
//                if error == nil, let updatedShare = share {
//                    DispatchQueue.main.async {
//                        participants = updatedShare.participants.filter { $0.role != .owner }.map { Participant($0) }
//                        emailAddress = ""
//                    }
//                } else {
//                    isValidInput = false
//                }
//                toggleProgress.toggle()
//            }
//        }
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegularExpression)
//        return predicate.evaluate(with: email)
//    }
//}
//
///**
// A structure that wraps CKShare.Participant and implements Equatable to trigger SwiftUI updates when any of the following states change:
// - userIdentity
// - acceptanceStatus
// - permission
// - role
// */
//private struct Participant: Hashable, Equatable {
//    let ckShareParticipant: CKShare.Participant
//
//    init(_ ckShareParticipant: CKShare.Participant) {
//        self.ckShareParticipant = ckShareParticipant
//    }
//
//    static func == (lhs: Participant, rhs: Participant) -> Bool {
//        let lhsElement = lhs.ckShareParticipant
//        let rhsElement = rhs.ckShareParticipant
//        
//        if lhsElement.userIdentity != rhsElement.userIdentity ||
//            lhsElement.acceptanceStatus != rhsElement.acceptanceStatus ||
//            lhsElement.permission != rhsElement.permission ||
//            lhsElement.role != rhsElement.role {
//            return false
//        }
//        return true
//    }
//}
//
//
////#Preview {
////    ParticipantView()
////}
