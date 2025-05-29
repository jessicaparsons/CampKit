//
//  MainView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/16/25.
//

import SwiftUI
import os
import CoreData

let log = Logger(subsystem: "co.junipercreative.CampKit", category: "Sharing")

struct MainView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(StoreKitManager.self) private var storeKitManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selection = 0
    
    @State private var isSettingsPresented: Bool = false
    @State private var isUpgradeToProPresented: Bool = false
    
    @State private var packingListsCount: Int = 0
    
    @State private var navigateToListView = false
    @State private var currentPackingList: PackingList?
    @State private var isEditing = false
    
    var body: some View {
            ZStack {
                
                TabView(selection: $selection) {
                    NavigationStack {
                        //MARK: - HOME
                        HomeListView(
                            context: viewContext,
                            packingListsCount: $packingListsCount,
                            selection: $selection,
                            navigateToListView: $navigateToListView,
                            currentPackingList: $currentPackingList,
                            isSettingsPresented: $isSettingsPresented,
                            isEditing: $isEditing
                        )
                        .navigationDestination(isPresented: $navigateToListView) {
                            if let packingList = currentPackingList {
                                ListView(
                                    context: viewContext,
                                    packingList: packingList,
                                    packingListsCount: packingListsCount
                                )
                            } else {
                                HomeListView(
                                    context: viewContext,
                                    packingListsCount: $packingListsCount,
                                    selection: $selection,
                                    navigateToListView: $navigateToListView,
                                    currentPackingList: $currentPackingList,
                                    isSettingsPresented: $isSettingsPresented,
                                    isEditing: $isEditing
                                )
                            }
                        }
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: selection == 0 ? "tent.fill" : "tent")
                                .environment(\.symbolVariants, .none)
                            Text("Home")
                        }
                    }
                    .tag(0)
                    
                    //MARK: - REMINDERS
                    NavigationStack {
                        RemindersView(
                            context: viewContext,
                            isSettingsPresented: $isSettingsPresented)
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: selection != 1  && colorScheme == .dark ? "alarm" : "alarm.fill")
                                .environment(\.symbolVariants, .none)
                            Text("Reminders")
                        }
                    }
                    .tag(1)
                    
                    
                    //MARK: - RESTOCK
                    NavigationStack {
                        RestockView(
                            context: viewContext,
                            isSettingsPresented: $isSettingsPresented)
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: selection != 2 && colorScheme == .dark ?  "arrow.clockwise.circle" : "arrow.clockwise.circle.fill")
                                .environment(\.symbolVariants, .none)
               
                            Text("Restock")
                        }
                    }
                    .tag(2)
                    
                }//:TABVIEW
                .toolbarBackground(Color(UIColor.tertiarySystemBackground), for: .tabBar)
                .tint(colorScheme == .light ? Color.colorForest : Color.colorSage)
                
                
                
            }//:ZSTACK
            .ignoresSafeArea(.keyboard) // So the button doesn't move on keyboard appearance
            
            
            .sheet(isPresented: $isUpgradeToProPresented) {
                UpgradeToProView()
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
                    .presentationDragIndicator(.visible)
            }
            .onChange(of: selection) {
                isEditing = false
            }
            // MARK: - CLOUD NOTIFICATIONS
            .onReceive(NotificationCenter.default.publisher(for: .didAcceptShare)) { _ in
                Task { @MainActor in
                    do {
                        try viewContext.setQueryGenerationFrom(.current)
                    } catch {
                        log.info("Failed to refresh query generation: \(error)")
                    }
                }
            }
    }
    
}


extension Notification.Name {
    static let didAcceptShare = Notification.Name("didAcceptShare")
}


#if DEBUG
#Preview {
    @Previewable @State var isDarkMode = false
    
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: CoreDataStack.preview.context)

    MainView()
        .environment(\.managedObjectContext, previewStack.context)
        .environment(StoreKitManager())
}
#endif

#if DEBUG
#Preview("Blank") {
    @Previewable @State var isDarkMode = false
    
    let previewStack = CoreDataStack.preview

    MainView()
        .environment(\.managedObjectContext, previewStack.context)
        .environment(StoreKitManager())
}
#endif
