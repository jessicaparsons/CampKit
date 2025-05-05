//
//  FloatingMenuView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/2/25.
//

import SwiftUI
import CoreData

struct FloatingMenuView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(StoreKitManager.self) private var storeKitManager

    @Bindable var viewModel: QuizViewModel
    
    @Binding var tabSelection: Int
    var packingListsCount: Int

    @State private var isMenuOpen = false
    @Binding var navigateToListView: Bool
    @Binding var isUpgradeToProPresented: Bool
    @Binding var isNewListQuizPresented: Bool
    @Binding var currentPackingList: PackingList?
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            if isMenuOpen {
                withAnimation {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }
                }
            }
            
            HStack {
                Spacer()
                
                VStack(alignment: .trailing, spacing: Constants.gridSpacing) {
                    
                    Spacer()
                    
                    if isMenuOpen {
                        
                        Group {
                            
                            
//                            Button {
//                                tabSelection = 2 // Restock tab
//                                isMenuOpen = false
//                            } label: {
//                                MenuItem(icon: "arrow.clockwise.circle.fill", label: "Restock")
//                            }
//                            
//                            Button {
//                                tabSelection = 1 // Reminders tab
//                                isMenuOpen = false
//                            } label: {
//                                MenuItem(icon: "alarm.fill", label: "Reminder")
//                            }
                            
                            //MARK: - BLANK PACKING LIST
                            Button {
                                viewModel.createBlankPackingList()
                                
                                if let packingList = viewModel.currentPackingList {
                                    currentPackingList = packingList
                                    navigateToListView = true
                                }
                                isMenuOpen = false
                            } label: {
                                MenuItem(icon: "clipboard", label: "Blank List")
                            }
                            
                            //MARK: - TEMPLATE PACKING LIST
                            MenuItem(icon: "list.clipboard", label: "Customized List")
                                .onTapGesture {
                                    if storeKitManager.isUnlimitedListsUnlocked || packingListsCount < Constants.proVersionListCount {
                                        isNewListQuizPresented = true
                                    } else {
                                        isUpgradeToProPresented.toggle()
                                    }
                                    isMenuOpen = false
                                }
                        }//:GROUP
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.trailing, 5)

                    }//:IF
                    
                    Button {
                        withAnimation(.spring()) {
                            isMenuOpen.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .fontWeight(.bold)
                            .rotationEffect(isMenuOpen ? .degrees(45) : .degrees(0))
                            .foregroundColor(Color.colorNeonDark)
                            .frame(width: 56, height: 56)
                            .background(Color.colorForest)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    

                }//:VSTACK
                .padding(.trailing, Constants.horizontalPadding)
                .padding(.bottom, Constants.largePadding)
            }//:HSTACK
        }//:ZSTACK
        .sheet(isPresented: $isUpgradeToProPresented) {
            UpgradeToProView()
        }
        
    }
}

struct MenuItem: View {
    var icon: String
    var label: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Color.colorWhiteForest)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.colorForest)
                .clipShape(RoundedRectangle(cornerRadius: 50))
            
            Image(systemName: icon)
                .foregroundColor(Color.colorNeonDark)
                .frame(width: 44, height: 44)
                .background(Color.colorForest)
                .clipShape(Circle())
        }
    }
}


#Preview {
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var isUpgradeToProPresented: Bool = false
    @Previewable @State var isNewListQuizPresented: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    @Previewable @State var tabSelection: Int = 1


    let context = CoreDataStack.shared.context
    let storeKitManager = StoreKitManager()
    
    
    FloatingMenuView(
        viewModel: QuizViewModel(context: context),
        tabSelection: $tabSelection,
        packingListsCount: 1,
        navigateToListView: $navigateToListView,
        isUpgradeToProPresented: $isUpgradeToProPresented,
        isNewListQuizPresented: $isNewListQuizPresented,
        currentPackingList: $currentPackingList
    )
    .environment(storeKitManager)
}
