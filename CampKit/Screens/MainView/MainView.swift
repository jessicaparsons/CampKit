//
//  MainView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/16/25.
//

import SwiftUI

struct MainView: View {
    
    @FetchRequest(
        entity: PackingList.entity(),
        sortDescriptors: [])
    var packingLists: FetchedResults<PackingList>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(StoreKitManager.self) private var storeKitManager
    let weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    
    @State private var selection = 0
    @State private var isSettingsPresented: Bool = false
    @State private var isNewListQuizPresented: Bool = false
    @State private var isStepOne: Bool = true
    @State private var navigateToListView = false
    @State private var currentPackingList: PackingList?
    @State private var isUpgradeToProPresented: Bool = false
    
    var packingListsCount: Int {
        packingLists.count
    }
    
    var body: some View {
        
            ZStack(alignment: .bottom) {
                TabView(selection: $selection) {
                        NavigationStack {
                            //MARK: - HOME
                            HomeListView(
                                context: viewContext,
                                isNewListQuizPresented: $isNewListQuizPresented
                            )
                                .navigationDestination(isPresented: $navigateToListView) {
                                    if let packingList = currentPackingList {
                                        ListView(
                                            context: viewContext,
                                            packingList: packingList,
                                            packingListsCount: packingListsCount
                                        )
                                    } else {
                                        HomeListView(context: viewContext, isNewListQuizPresented: $isNewListQuizPresented)
                                    }
                                }
                        }
                        .tabItem {
                            Image(systemName: "list.bullet")
                        }
                        .tag(0)
                        
                        //MARK: - REMINDERS
                        NavigationStack {
                            RemindersView(context: viewContext)
                        }
                        .tabItem {
                            Image(systemName: "alarm")
                        }
                        .tag(1)
                        
                        //MARK: - CENTER BUTTON
                        Spacer()
                            .tabItem {
                                EmptyView()
                            }
                            .tag(2)
                        
                        //MARK: - RESTOCK
                        NavigationStack {
                            RestockView(context: viewContext)
                        }
                        .tabItem {
                            Image(systemName: "arrow.clockwise.square")
                        }
                        .tag(3)
                        
                        //MARK: - SETTINGS
                        NavigationStack {
                            SettingsView()
                        }
                        .tabItem {
                            Image(systemName: "gearshape")
                        }
                        .tag(4)
                    
                }//:TABVIEW
                .toolbarBackground(Color(UIColor.tertiarySystemBackground), for: .tabBar)
                
                //MARK: - CENTER ADD NEW LIST BUTTON
                Button {
                    if storeKitManager.isUnlimitedListsUnlocked || packingLists.count < Constants.proVersionListCount {
                        isNewListQuizPresented = true
                    } else {
                        isUpgradeToProPresented.toggle()
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
            .sheet(isPresented: $isNewListQuizPresented) {
                NavigationStack {
                    QuizView(
                        viewModel: QuizViewModel(context: viewContext),
                        isNewListQuizPresented: $isNewListQuizPresented,
                        isStepOne: $isStepOne,
                        navigateToListView: $navigateToListView,
                        currentPackingList: $currentPackingList,
                        packingListCount: packingListsCount
                    )
                    .environment(weatherViewModel)
                }
            }
            .sheet(isPresented: $isUpgradeToProPresented) {
                UpgradeToProView()
            }
            
    }
    
}

#Preview {

    MainView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environment(StoreKitManager())
}
