//
//  MainView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/16/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var packingLists: [PackingList]
    
    @State private var selection = 0
    @State private var isShowingSettings: Bool = false
    @State private var isNewListQuizShowing: Bool = false
    @State private var isStepOne: Bool = true
    @State private var navigateToListView = false
    @State private var currentPackingList: PackingList?
    private var storeKitManager = StoreKitManager()
    @State private var isUpgradeToProShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selection) {
                    Group {
                        HomeListView(modelContext: modelContext, storeKitManager: storeKitManager, isNewListQuizShowing: $isNewListQuizShowing, isUpgradeToProShowing: $isUpgradeToProShowing)
                            .tabItem {
                                Image(systemName: "list.bullet")
                            }
                            .tag(0)
                        
                        RemindersView()
                            .tabItem {
                                Image(systemName: "bell")
                            }
                            .tag(1)
                        
                        Spacer()
                            .tabItem {
                                EmptyView()
                            }
                            .tag(2)
                        
                        RestockView()
                            .tabItem {
                                Image(systemName: "arrow.clockwise.square")
                            }
                            .tag(3)
                        
                        SettingsView()
                            .padding(.horizontal)
                            .tabItem {
                                Image(systemName: "gearshape")
                            }
                            .tag(4)
                    }//:GROUP
                    .toolbarBackground(Color(UIColor.tertiarySystemBackground), for: .tabBar)
                }//:TABVIEW
                
                Button {
                    if storeKitManager.isUnlimitedListsUnlocked || packingLists.count < 3 {
                        isNewListQuizShowing = true
                    } else {
                        isUpgradeToProShowing = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.palette)
                        .font(.system(size: 38))
                        .foregroundStyle(.black, Color(Color.colorNeon))
                        .offset(y: -10)
                }
            }//:ZSTACK
            .ignoresSafeArea(.keyboard) // So the button doesn't move on keyboard appearance
            .onChange(of: selection) { oldValue, newValue in
                if newValue == 2 {
                    selection = oldValue // Revert to the previous tab
                }
            }
            //MARK: - SHOW PACKING LIST QUIZ
            .sheet(isPresented: $isNewListQuizShowing) {
                NavigationStack {
                    QuizView(
                        viewModel: QuizViewModel(modelContext: modelContext),
                        isNewListQuizShowing: $isNewListQuizShowing,
                        isStepOne: $isStepOne,
                        navigateToListView: $navigateToListView,
                        currentPackingList: $currentPackingList
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToListView) {
                if let packingList = currentPackingList {
                    ListView(viewModel: ListViewModel(modelContext: modelContext, packingList: packingList))
                } else {
                    HomeListView(modelContext: modelContext, storeKitManager: storeKitManager, isNewListQuizShowing: $isNewListQuizShowing, isUpgradeToProShowing: $isUpgradeToProShowing)
                }
            }//:ZSTACK
        }//:NAVIGATION STACK
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    preloadPackingListData(context: container.mainContext)
    
    return MainView()
        .modelContainer(container)
}

