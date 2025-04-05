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
                    if storeKitManager.isUnlimitedListsUnlocked || packingListsCount < 3 {
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
            }//:ZSTACK
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
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    preloadPackingListData(context: container.mainContext)
    
    return MainView()
        .modelContainer(container)
}

