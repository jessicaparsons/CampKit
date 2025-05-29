//
//  ContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import CoreData

struct HomeListView: View {
    
    
    let weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeListViewModel
    @State private var quizViewModel: QuizViewModel
    @Environment(StoreKitManager.self) private var storeKitManager
    
    @State private var isMenuOpen = false
    @State private var location: String = ""
    @State private var isNewListQuizPresented: Bool = false
    @State private var isUpgradeToProPresented: Bool = false
    @State private var currentStep: Int = 1
    @Binding var navigateToListView: Bool
    @Binding var currentPackingList: PackingList?
    @Binding var packingListsCount: Int
    @Binding var selection: Int
    @Binding var isSettingsPresented: Bool
    @State private var isDeleteConfirmationPresented: Bool = false
    @State private var isEditing = false

    
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
        _viewModel = StateObject(wrappedValue: HomeListViewModel(viewContext: context))
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
                    
                    whereToNextButton
                    
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
                    
                    if viewModel.packingLists.isEmpty {
                        
                        EmptyContentView(
                            icon: "tent.fill",
                            description: "It looks like you don’t have any lists yet")
                        
                        .padding(.top, Constants.largePadding)
                        
                    } else {
                        
                        LazyVGrid(columns: gridItem, alignment: .center) {
                            ForEach(viewModel.packingLists) { packingList in
                                
                                    HomeListCardView(
                                        viewModel: viewModel,
                                        packingList: packingList,
                                        isEditing: $isEditing,
                                        isDeleteConfirmationPresented: $isDeleteConfirmationPresented
                                    )
                                    .onTapGesture {
                                        currentPackingList = packingList
                                        navigateToListView = true
                                    }
                                    
                      
                                
                            }//:FOREACH
                        }//:LAZYVGRID
                        .scrollContentBackground(.hidden)
                        .refreshable {
                            await refresh(context: viewContext)
                        }
                    }//:ELSE
                }//:VSTACK
                .padding(.horizontal, Constants.wideMargin)
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
            viewModel.fetchPackingLists()
            packingListsCount = viewModel.packingLists.count
        }
        .onChange(of: viewModel.packingLists.count) {
            packingListsCount = viewModel.packingLists.count
        }
        //MARK: - SHOW PACKING LIST QUIZ
        .sheet(isPresented: $isNewListQuizPresented) {
            NavigationStack {
                QuizView(
                    viewModel: quizViewModel,
                    isNewListQuizPresented: $isNewListQuizPresented,
                    currentStep: $currentStep,
                    navigateToListView: $navigateToListView,
                    currentPackingList: $currentPackingList,
                    packingListCount: viewModel.packingLists.count
                )
                .environment(weatherViewModel)
            }
        }
        .sheet(isPresented: $isUpgradeToProPresented) {
            UpgradeToProView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !isEditing {
                    
                    HStack {
                        Menu {
                            //SORT BY
                            Label("Sort By", systemImage: "arrow.up.arrow.down")
                            
                            Button {
                                withAnimation {
                                    viewModel.selectedSort = "Date"
                                }
                            } label: {
                                if viewModel.selectedSort == "Date" {
                                    Label("Date", systemImage: "checkmark")
                                } else {
                                    Text("Date")
                                }
                            }
                            Button {
                                withAnimation {
                                    viewModel.selectedSort = "Name"
                                }
                            } label: {
                                if viewModel.selectedSort == "Name" {
                                    Label("Name", systemImage: "checkmark")
                                } else {
                                    Text("Name")
                                }
                            }
                            Divider()
                            
                            Button(role: .destructive) {
                                isEditing = true
                                HapticsManager.shared.triggerLightImpact()
                            } label: {
                                Label("Delete a list", systemImage: "trash")
                            }
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                                .foregroundStyle(Color.colorForestSecondary)
                        }//:MENU
                        
                        //SETTINGS
                        Button {
                            isSettingsPresented.toggle()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color.colorForestSecondary)
                        }
                    }//:HSTACK
                } else {
                    Button {
                        isEditing = false
                    } label: {
                        Text("Done")
                    }
                }
                
            }//:TOOL BAR ITEM
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }//:BODY
    
    var whereToNextButton: some View {
        Button {
            isNewListQuizPresented = true
            HapticsManager.shared.triggerLightImpact()
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
    }
    
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
