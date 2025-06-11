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
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @StateObject private var viewModel: HomeListViewModel
    @State private var quizViewModel: QuizViewModel
    @Environment(StoreKitManager.self) private var storeKitManager
    
    @State private var location: String = ""
    
    //ALERTS AND SHEETS
    @State private var isMenuOpen = false
    @State private var isNewListQuizPresented: Bool = false
    @State private var isNewListQuizPresentediPad: Bool = false
    @State private var isUpgradeToProPresented: Bool = false
    @State private var isDeleteConfirmationPresented: Bool = false
    
    //QUIZ
    @State private var currentStep: Int = 1
    
    //UI
    @State private var scrollOffset: CGFloat = 0
    
    //BINDINGS
    @Binding var navigateToListView: Bool
    @Binding var currentPackingList: PackingList?
    @Binding var packingListsCount: Int
    @Binding var selection: Int
    @Binding var isSettingsPresented: Bool
    @Binding var isEditing: Bool
    
    @State private var listToDelete: PackingList?
    
    
    private let stack = CoreDataStack.shared
    
    private var gridItem: [GridItem] {
        if sizeClass == .regular {
            return Array(repeating: GridItem(.flexible(), spacing: Constants.horizontalPadding), count: 3) // iPad layout
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: Constants.horizontalPadding), count: 2) // iPhone layout
        }
    }
    
    init(
        context: NSManagedObjectContext,
        packingListsCount: Binding<Int>,
        selection: Binding<Int>,
        navigateToListView: Binding<Bool>,
        currentPackingList: Binding<PackingList?>,
        isSettingsPresented: Binding<Bool>,
        isEditing: Binding<Bool>
    ) {
        _packingListsCount = packingListsCount
        _selection = selection
        _viewModel = StateObject(wrappedValue: HomeListViewModel(viewContext: context))
        _quizViewModel = State(wrappedValue: QuizViewModel(context: context))
        _navigateToListView = navigateToListView
        _currentPackingList = currentPackingList
        _isSettingsPresented = isSettingsPresented
        _isEditing = isEditing
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
                        Text("Adventure awaits")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 12)
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
                            .padding(.top, 25)
                            .padding(.bottom, 12)
                        Spacer()
                    }//:HSTACK
                    
                    if viewModel.packingLists.isEmpty {
                        
                        EmptyContentView(
                            icon: "tent.fill",
                            description: "It looks like you don’t have any lists yet")
                        
                        .padding(.top, Constants.largePadding)
                        
                    } else {
                        
                        LazyVGrid(columns: gridItem, alignment: .center, spacing: Constants.cardSpacing) {
                            ForEach(viewModel.packingLists) { packingList in
                                
                                    HomeListCardView(
                                        viewModel: viewModel,
                                        packingList: packingList,
                                        isEditing: $isEditing
                                    )
                                    .onTapGesture {
                                        isEditing = false
                                        currentPackingList = packingList
                                        navigateToListView = true
                                    }
                                    .overlay(alignment: .topLeading) {
                                        if isEditing {
                                            Button(action: {
                                                listToDelete = packingList
                                                isDeleteConfirmationPresented = true
                                            }) {
                                                ZStack(alignment: .topLeading) {
                                                    Color.clear
                                                        .frame(width: 60, height: 60)
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.red)
                                                            .frame(width: 26, height: 26)
                                                        
                                                        Image(systemName: "minus")
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 14, weight: .bold))
                                                            .accessibilityLabel("Delete")
                                                    }//:ZSTACK
                                                    .padding(6)
                                                    .offset(x: -12, y: -12)
                                                        
                                                }
                                                
                                            }
                                            .accessibilityHint("Delete packing list")
                                        }
                                    }
                                    
                      
                                
                            }//:FOREACH
                        }//:LAZYVGRID
                        .scrollContentBackground(.hidden)
                        .refreshable {
                            await refresh(context: viewContext)
                        }
                    }//:ELSE
                }//:VSTACK
                .padding(.bottom, Constants.bodyPadding)
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
                .confirmationDialog(
                    "Are you sure you want to delete this list?",
                    isPresented: $isDeleteConfirmationPresented,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        if let list = listToDelete {
                            viewModel.delete(list)
                            HapticsManager.shared.triggerSuccess()
                            save(viewContext)
                        }
                      
                    }
                    .accessibilityHint("Delete list")
                    
                    Button("Cancel", role: .cancel) { }
                        .accessibilityHint("Cancel deletion")
                }
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
                    if storeKitManager.isProUnlocked || packingListsCount < Constants.proVersionListCount {
                        quizViewModel.createBlankPackingList()
                        
                        if let packingList = quizViewModel.currentPackingList {
                            currentPackingList = packingList
                            navigateToListView = true
                        }
                    } else {
                        isUpgradeToProPresented.toggle()
                    }
                    isMenuOpen = false
                },
                buttonTwoImage: "list.clipboard",
                buttonTwoLabel: "Customized List",
                buttonTwoAction: {
                    if storeKitManager.isProUnlocked || packingListsCount < Constants.proVersionListCount {
                        
                        if sizeClass == .regular {
                            isNewListQuizPresentediPad = true
                        } else {
                            isNewListQuizPresented = true
                        }
                        
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
        .onChange(of: isMenuOpen) {
            if isMenuOpen {
                isEditing = false
            }
        }
        //MARK: - SHOW PACKING LIST QUIZ
        .fullScreenCover(isPresented: $isNewListQuizPresentediPad) {
            NavigationStack {
                QuizView(
                    viewModel: quizViewModel,
                    isNewListQuizPresented: $isNewListQuizPresentediPad,
                    currentStep: $currentStep,
                    navigateToListView: $navigateToListView,
                    currentPackingList: $currentPackingList,
                    packingListCount: viewModel.packingLists.count
                )
                .environment(weatherViewModel)
            }
        }
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
                            .accessibilityHint("Delete a list")
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                                .foregroundStyle(Color.colorForestSecondary)
                                .accessibilityLabel("Menu")
                        }//:MENU
                        
                        //SETTINGS
                        Button {
                            isSettingsPresented.toggle()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color.colorForestSecondary)
                                .accessibilityLabel("Settings")
                        }
                    }//:HSTACK
                } else {
                    Button {
                        isEditing = false
                    } label: {
                        Text("Done")
                            .fontWeight(.bold)
                    }
                }
                
            }//:TOOL BAR ITEM
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }//:BODY
    
    var whereToNextButton: some View {
        Button {
            if storeKitManager.isProUnlocked || packingListsCount < Constants.proVersionListCount {
                
                if sizeClass == .regular {
                    isNewListQuizPresentediPad = true
                } else {
                    isNewListQuizPresented = true
                }
                HapticsManager.shared.triggerLightImpact()
                
            } else {
                isUpgradeToProPresented.toggle()
            }
            
            
        } label: {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.cornerRadiusButton)
                        .fill(Color.colorWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.cornerRadiusButton)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                        .frame(height: 50)
                        .shadow(color: Color.black.opacity(0.1), radius: 8)
                    
                    HStack {
                        Image(systemName: "tent.circle")
                            .foregroundColor(Color.colorNeon)
                            .frame(width: 35, height: 35)
                            .background(Color.colorSecondaryIcon)
                            .clipShape(Circle())
                            .padding(.leading, 10)
                            .font(.system(size: 24, weight: .light))
                        Text("Let's get packing")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.secondary)
                            .padding(.trailing)
                    }//:HSTACK
                }//:ZSTACK
                .frame(maxWidth: sizeClass == .regular ? 300 : .infinity, alignment: .leading)
                Spacer()
            }//:HSTACK
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
    @Previewable @State var isEditing: Bool = false
    
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: previewStack.context)
    let list2 = PackingList.samplePackingList(context: previewStack.context)
    let list3 = PackingList.samplePackingList(context: previewStack.context)
    let list4 = PackingList.samplePackingList(context: previewStack.context)
    let list5 = PackingList.samplePackingList(context: previewStack.context)
    let list6 = PackingList.samplePackingList(context: previewStack.context)
    
    NavigationStack {
        HomeListView(
            context: previewStack.context,
            packingListsCount: $packingListsCount,
            selection: $selection,
            navigateToListView: $navigateToListView,
            currentPackingList: $currentPackingList,
            isSettingsPresented: $isSettingsPresented,
            isEditing: $isEditing
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
    @Previewable @State var isEditing: Bool = false
    
    let previewStack = CoreDataStack.preview
    
    NavigationStack {
        HomeListView(
            context: previewStack.context,
            packingListsCount: $packingListsCount,
            selection: $selection,
            navigateToListView: $navigateToListView,
            currentPackingList: $currentPackingList,
            isSettingsPresented: $isSettingsPresented,
            isEditing: $isEditing
        )
        .environment(\.managedObjectContext, previewStack.context)
        .environment(StoreKitManager())
        
    }
}


#endif
