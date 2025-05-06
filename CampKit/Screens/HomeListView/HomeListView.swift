//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import CoreData

struct HomeListView: View {
    //Live Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PackingList.position, ascending: true)]
    ) var packingLists: FetchedResults<PackingList>

    let weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var quizViewModel: QuizViewModel
    @Environment(StoreKitManager.self) private var storeKitManager
    
    @State private var isMenuOpen = false
    
    @State private var location: String = ""
    @State private var editMode: EditMode = .inactive
    @State private var isNewListQuizPresented: Bool = false
    @State private var isUpgradeToProPresented: Bool = false
    @State private var isStepOne: Bool = true
    @Binding var navigateToListView: Bool
    @Binding var currentPackingList: PackingList?
    @Binding var packingListsCount: Int
    @Binding var selection: Int
    @Binding var isSettingsPresented: Bool
    
    @State private var scrollOffset: CGFloat = 0
    
    private let stack = CoreDataStack.shared
    
    private let gridItem: [GridItem] = Array(repeating: .init(.flexible(), spacing: Constants.horizontalPadding), count: 2)
    
    
    init(
        context: NSManagedObjectContext,
        packingListsCount: Binding<Int>,
        selection: Binding<Int>,
        navigateToListView: Binding<Bool>,
        currentPackingList: Binding<PackingList?>,
        isSettingsPresented: Binding<Bool>
    ) {
        _packingListsCount = packingListsCount
        _selection = selection
        _quizViewModel = State(wrappedValue: QuizViewModel(context: context))
        _navigateToListView = navigateToListView
        _currentPackingList = currentPackingList
        _isSettingsPresented = isSettingsPresented
    }
    
    var body: some View {
        //MARK: - HEADER
        ZStack(alignment: .top) {
            
            //MARK: - BACKGROUND STYLES
            Color.colorWhiteSands
                .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        
                        //MARK: - WHERE TO NEXT?
                        
                        HStack {
                            Text("Let's get packing")
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom)
                            Spacer()
                        }//:HSTACK
                        .padding(.top, Constants.headerSpacing)
                        
                        Button {
                            isNewListQuizPresented = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color.colorWhite)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 50)
                                            .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                                    )
                                    .frame(height: 50)
                                
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(Color.colorNeon)
                                        .frame(width: 35, height: 35)
                                        .background(Color.colorSecondaryIcon)
                                        .clipShape(Circle())
                                        .padding(.leading, 10)
                                    Text("Where to next?")
                                        .foregroundStyle(Color.secondary)
                                    Spacer()
                                    
                                }//:HSTACK
                                
                            }//:ZSTACK
                        }//:BUTTON
                        
                        
                        //MARK: - PACKING LISTS
                        
                        
                        HStack {
                            Text("Your lists")
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .padding(.top, Constants.largePadding)
                                .padding(.bottom)
                            Spacer()
                        }//:HSTACK
                        
                        if packingLists.isEmpty {
                            
                            EmptyContentView(
                                icon: "tent.fill",
                                description: "It looks like you don’t have any lists yet")
                            
                            .padding(.top, Constants.largePadding)
                            
                        } else {
                            
                            LazyVGrid(columns: gridItem, alignment: .center) {
                                ForEach(packingLists) { packingList in
                                    
                                    NavigationLink(
                                        destination: ListView(
                                            context: viewContext,
                                            packingList: packingList,
                                            packingListsCount: packingLists.count
                                        ),
                                        label: {
                                            HomeListCardView(packingList: packingList)
                                        }
                                    )//:NAVIGATION LINK
                                } //:FOR EACH
                                .onMove { indices, newOffset in
                                    var reorderedLists = packingLists.map { $0 }
                                    
                                    reorderedLists.move(fromOffsets: indices, toOffset: newOffset)
                                    
                                    for (index, item) in reorderedLists.enumerated() {
                                        item.position = Int64(index)
                                    }
                                    
                                    save(viewContext)
                                }
                                
                                
                                .onDelete { offsets in
                                    for index in offsets {
                                        let list = packingLists[index]
                                        if stack.canDelete(object: list) {
                                            viewContext.delete(list)
                                        }
                                    }
                                    save(viewContext)
                                }
                            }//:LAZYVGRID
                            .scrollContentBackground(.hidden)
                            .refreshable {
                                await refresh(context: viewContext)
                            }
                        }//:ELSE
                    }//:VSTACK
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .frame(height: 0)
                                .onChange(of: geo.frame(in: .global).minY) {
                                    scrollOffset = geo.frame(in: .global).minY
                                }
                        }
                    )//NAV BAR UI CHANGES ON SCROLL
                }//:SCROLLVIEW
                .scrollIndicators(.hidden)
                .padding(.horizontal, Constants.wideMargin)
                
            
            
            //MARK: - HEADER
            
            HeaderView(
                title: "Howdy, Camper!",
                scrollOffset: $scrollOffset,
                scrollThreshold: -70
            )
            
            //MARK: - FLOATING MENU
            
            FloatingMenuView(
                isMenuOpen: $isMenuOpen,
                buttonOneImage: "clipboard",
                buttonOneLabel: "Blank List",
                buttonOneAction: {
                    quizViewModel.createBlankPackingList()
                    
                    if let packingList = quizViewModel.currentPackingList {
                        currentPackingList = packingList
                        navigateToListView = true
                    }
                    isMenuOpen = false
                },
                buttonTwoImage: "list.clipboard",
                buttonTwoLabel: "Customized List",
                buttonTwoAction: {
                    if storeKitManager.isUnlimitedListsUnlocked || packingListsCount < Constants.proVersionListCount {
                        isNewListQuizPresented = true
                    } else {
                        isUpgradeToProPresented.toggle()
                    }
                    isMenuOpen = false
                }
            )
            
        }//:ZSTACK
        .onAppear {
            packingListsCount = packingLists.count
        }
        .onChange(of: packingLists.count) {
            packingListsCount = packingLists.count
        }
        .environment(\.editMode, $editMode)
        //MARK: - SHOW PACKING LIST QUIZ
        .sheet(isPresented: $isNewListQuizPresented) {
            NavigationStack {
                QuizView(
                    viewModel: quizViewModel,
                    isNewListQuizPresented: $isNewListQuizPresented,
                    isStepOne: $isStepOne,
                    navigateToListView: $navigateToListView,
                    currentPackingList: $currentPackingList,
                    packingListCount: packingLists.count
                )
                .environment(weatherViewModel)
            }
        }
        .sheet(isPresented: $isUpgradeToProPresented) {
            UpgradeToProView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSettingsPresented.toggle()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(Color.colorForestSecondary)
                }
            }//:TOOL BAR ITEM
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }//:BODY
    
    
    
}//:STRUCT


#if DEBUG
#Preview() {
    
    @Previewable @State var selection = 0
    @Previewable @State var packingListsCount = 1
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    @Previewable @State var navigateToListView = false
    @Previewable @State var currentPackingList: PackingList?
    @Previewable @State var isSettingsPresented: Bool = false
    
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: previewStack.context)
    let list2 = PackingList.samplePackingList(context: previewStack.context)
    
    NavigationStack {
        HomeListView(
            context: previewStack.context,
            packingListsCount: $packingListsCount,
            selection: $selection,
            navigateToListView: $navigateToListView,
            currentPackingList: $currentPackingList,
            isSettingsPresented: $isSettingsPresented
        )
        .environment(\.managedObjectContext, previewStack.context)
        .environment(StoreKitManager())
            
    }
}

#Preview("Blank") {
    
    @Previewable @State var selection = 0
    @Previewable @State var packingListsCount = 1
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    @Previewable @State var navigateToListView = false
    @Previewable @State var currentPackingList: PackingList?
    @Previewable @State var isSettingsPresented: Bool = false
    
    let previewStack = CoreDataStack.preview
    
    NavigationStack {
        HomeListView(
            context: previewStack.context,
            packingListsCount: $packingListsCount,
            selection: $selection,
            navigateToListView: $navigateToListView,
            currentPackingList: $currentPackingList,
            isSettingsPresented: $isSettingsPresented
        )
        .environment(\.managedObjectContext, previewStack.context)
        .environment(StoreKitManager())
            
    }
}


#endif
