//
//  MainView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/16/25.
//

import SwiftUI

struct MainView: View {
    
    @FetchRequest(sortDescriptors: []) var packingLists: FetchedResults<PackingList>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(StoreKitManager.self) private var storeKitManager
    let weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    
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
        
            ZStack(alignment: .bottom) {
                TabView(selection: $selection) {
                        NavigationStack {
                            //MARK: - HOME
                            HomeListView(
                                context: viewContext,
                                isNewListQuizShowing: $isNewListQuizShowing
                            )
                                .navigationDestination(isPresented: $navigateToListView) {
                                    if let packingList = currentPackingList {
                                        ListView(
                                            context: viewContext,
                                            packingList: packingList,
                                            packingListsCount: packingListsCount
                                        )
                                    } else {
                                        HomeListView(context: viewContext, isNewListQuizShowing: $isNewListQuizShowing)
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
                            Image(systemName: "bell")
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
                    isNewListQuizShowing = true
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
                        viewModel: QuizViewModel(context: viewContext),
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
            
    }
    
}

#Preview {
    let context = PersistenceController.preview.container.viewContext

    MainView()
        .environment(\.managedObjectContext, context)
        .environment(StoreKitManager())
}
