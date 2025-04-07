//
//  MainView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/16/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    @Query var packingLists: [PackingList]

    @Environment(\.modelContext) var modelContext
    @Environment(StoreKitManager.self) private var storeKitManager
    let weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient())
    
    @State private var selection = 0
    @State private var isShowingSettings: Bool = false
    @State private var isNewListQuizShowing: Bool = false
    @State private var isStepOne: Bool = true
    @State private var navigateToListView = false
    @State private var currentPackingList: PackingList?
    @State private var isUpgradeToProShowing: Bool = false
    
    var packingListsCount: Int {
        packingLists.count
    }
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                TabView(selection: $selection) {
                    Group {
                        NavigationStack {
                            HomeListView(modelContext: modelContext, isNewListQuizShowing: $isNewListQuizShowing)
                        }
                        .tabItem {
                            Image(systemName: "list.bullet")
                        }
                        .tag(0)
                        
                        NavigationStack {
                            RemindersView()
                        }
                        .tabItem {
                            Image(systemName: "bell")
                        }
                        .tag(1)
                        
                        NavigationStack {
                            RestockView(viewModel: RestockViewModel(modelContext: modelContext))
                        }
                        .tabItem {
                            Image(systemName: "arrow.clockwise.square")
                        }
                        .tag(2)
                        NavigationStack {
                            SettingsView()
                        }
                        .padding(.horizontal)
                        .tabItem {
                            Image(systemName: "gearshape")
                        }
                        .tag(3)
                    }//:GROUP
                    .toolbarBackground(Color(UIColor.tertiarySystemBackground), for: .tabBar)
                }//:TABVIEW
            }//:ZSTACK
            
            //MARK: - SHOW PACKING LIST QUIZ
            .sheet(isPresented: $isNewListQuizShowing) {
                NavigationStack {
                    QuizView(
                        viewModel: QuizViewModel(modelContext: modelContext),
                        isNewListQuizShowing: $isNewListQuizShowing,
                        isStepOne: $isStepOne,
                        navigateToListView: $navigateToListView,
                        currentPackingList: $currentPackingList,
                        packingListCount: packingListsCount
                    )
                    .environment(weatherViewModel)
                }
            }
            .sheet(isPresented: Binding(
                get: { storeKitManager.isUpgradeToProShowing },
                set: { storeKitManager.isUpgradeToProShowing = $0 })
            ) {
                UpgradeToProView()
            }
            .navigationDestination(isPresented: $navigateToListView) {
                if let packingList = currentPackingList {
                    ListView(
                        viewModel: ListViewModel(modelContext: modelContext, packingList: packingList),
                        packingListsCount: packingListsCount)
                } else {
                    HomeListView(modelContext: modelContext, isNewListQuizShowing: $isNewListQuizShowing)
                }
            }
        }//:NAVIGATIONSTACK
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self, RestockItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    for item in RestockItem.restockItems {
        container.mainContext.insert(item)
    }
    
    preloadPackingListData(context: container.mainContext)
    
    return MainView()
            .modelContainer(container)
            .environment(StoreKitManager())
    
}

