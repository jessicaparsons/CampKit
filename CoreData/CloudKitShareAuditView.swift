//
//  CloudKitShareAuditView.swift
//  CampKit
//
//  Created by Jessica Parsons on 6/3/25.
//

import SwiftUI
import CoreData
import CloudKit

struct CloudKitShareAuditView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var viewModel: HomeListViewModel
    @State private var auditResults: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button("Run Share Audit") {
                Task {
                    await runAudit()
                }
            }
            
            Button("Share 'Joshua Tree'") {
                
                if let list = viewModel.packingLists.first(where: { $0.title == "Joshua Tree" }) {
                    Task {
                        await safeShare(packingList: list, context: viewContext, stack: CoreDataStack.shared)
                    }
                }
            }

            
            
            ScrollView {
                ForEach(auditResults, id: \.self) { result in
                    Text(result)
                        .font(.system(.body, design: .monospaced))
                        .padding(.bottom, 4)
                }
            }
            .padding()
        }
        .navigationTitle("Share Audit")
        .padding()
    }
    
    func safeShare(packingList: PackingList, context: NSManagedObjectContext, stack: CoreDataStack) async {
        do {
            print("🚀 Starting share for: \(packingList.title ?? "Untitled")")

            // ✅ STEP 1: Save pending changes
            if context.hasChanges {
                try context.save()
                print("💾 Saved unsaved changes.")
            } else {
                print("✅ No pending changes to save.")
            }

            // ✅ STEP 2: Fault in the object (ensure it's fully realized in Core Data)
            _ = try? context.existingObject(with: packingList.objectID)
            print("🔎 Fetched object back via objectID.")

            // ✅ STEP 3: Wait for CloudKit to hopefully upload record
            print("⏳ Sleeping for 3 seconds to allow iCloud push...")
            try await Task.sleep(nanoseconds: 3_000_000_000)

            // ✅ STEP 4: Create the share
            print("🔗 Attempting share...")
            let (_, share, _) = try await stack.persistentContainer.share([packingList], to: nil)

            // ✅ STEP 5: Customize metadata
            share[CKShare.SystemFieldKey.title] = packingList.title ?? "Untitled"
            print("📝 Set share title metadata.")

            // ✅ STEP 6: Persist the share and trigger UI
            await MainActor.run {
                stack.persistentContainer.persistUpdatedShare(share, in: stack.sharedPersistentStore)
                try? context.save()
                print("✅ Share persisted and saved to Core Data.")
            }

            print("🎉 Share created successfully!")

        } catch {
            print("❌ Error during share: \(error.localizedDescription)")
        }
    }


    func runAudit() async {
        auditResults.removeAll()
        let context = CoreDataStack.shared.context
        let container = CoreDataStack.shared.persistentContainer

        for list in viewModel.packingLists {
            var log = "🧾 List: \(list.title ?? "Untitled")"

            if let store = list.objectID.persistentStore {
                log += "\n - Store: \(store.configurationName)"
            }

            do {
                let shareMap = try container.fetchShares(matching: [list.objectID])
                if let share = shareMap[list.objectID] {
                    log += "\n ✅ CKShare exists"
                    if let owner = share.owner.userIdentity.nameComponents {
                        log += "\n    - Owner: \(owner.givenName ?? "Unknown")"
                    } else {
                        log += "\n    - Owner: Unknown"
                    }
                } else {
                    log += "\n ❌ No CKShare found"
                }
            } catch {
                log += "\n ❌ Error fetching CKShare: \(error.localizedDescription)"
            }

            auditResults.append(log)
        }
    }
}

#if DEBUG
#Preview {
    let previewStack = CoreDataStack.preview
    
    CloudKitShareAuditView(viewModel: HomeListViewModel(viewContext: previewStack.context))
}
#endif
