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
    @Environment(StoreKitManager.self) private var storeKitManager
    let weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient())
    
    @State private var selection = 0
    @State private var isShowingSettings: Bool = false
    @State private var isNewListQuizShowing: Bool = false
    @State private var isStepOne: Bool = true
    @State private var navigateToListView = false
    @State private var currentPackingList: PackingList?
    @State private var isUpgradeToProShowing: Bool = false
    @State private var packingListsCount: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selection) {
                    Group {
                        HomeListView(modelContext: modelContext, isNewListQuizShowing: $isNewListQuizShowing)
                            .tabItem {
                                Image(systemName: "list.bullet")
                            }
                            .tag(0)
                        
                        RemindersView()
                            .tabItem {
                                Image(systemName: "bell")
                            }
                            .tag(1)
                        
                        RestockView()
                            .tabItem {
                                Image(systemName: "arrow.clockwise.square")
                            }
                            .tag(2)
                        
                        SettingsView()
                            .padding(.horizontal)
                            .tabItem {
                                Image(systemName: "gearshape")
                            }
                            .tag(3)
                    }//:GROUP
                    .toolbarBackground(Color(UIColor.tertiarySystemBackground), for: .tabBar)
                }//:TABVIEW
            }//:ZSTACK
            .ignoresSafeArea(.keyboard) // So the button doesn't move on keyboard appearance
            
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
        }//:NAVIGATION STACK
        .task {
            do {
                let descriptor = FetchDescriptor<PackingList>()
                packingListsCount = try modelContext.fetchCount(descriptor)
            } catch {
                print("Error fetching packing list count: \(error)")
            }
        }
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
    
    return NavigationView {
        MainView()
            .modelContainer(container)
            .environment(StoreKitManager())
    }
}

