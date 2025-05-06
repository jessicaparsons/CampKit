//
//  FloatingMenuView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/2/25.
//

import SwiftUI
import CoreData

struct FloatingMenuView: View {
    
    @Binding var isMenuOpen: Bool
    
    let buttonOneImage: String
    let buttonOneLabel: String
    let buttonOneAction: () -> Void
    
    let buttonTwoImage: String
    let buttonTwoLabel: String
    let buttonTwoAction: () -> Void
    
    
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
                            
                            
                            //MARK: - BLANK PACKING LIST
                            MenuItem(icon: buttonOneImage, label: buttonOneLabel)
                                .onTapGesture(perform: buttonOneAction)
                            
                            //MARK: - TEMPLATE PACKING LIST
                            MenuItem(icon: buttonTwoImage, label: buttonTwoLabel)
                                .onTapGesture(perform: buttonTwoAction)
                            
                            
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
    @Previewable @State var isMenuOpen: Bool = false

    let context = CoreDataStack.shared.context
    let storeKitManager = StoreKitManager()
    
    
    FloatingMenuView(
        isMenuOpen: $isMenuOpen,
        buttonOneImage: "clipboard",
        buttonOneLabel: "Blank List",
        buttonOneAction: {},
        buttonTwoImage: "list.clipboard",
        buttonTwoLabel: "Customized List",
        buttonTwoAction: {}
    )
}
