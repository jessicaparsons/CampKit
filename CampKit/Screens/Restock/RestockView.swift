//
//  RestockView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import CoreData

struct RestockView: View {
    
    @State var viewModel: RestockViewModel
     
    @Binding var isSettingsPresented: Bool
    @State private var isPickerFocused: Bool = false
    @State private var isAddNewItemPresented: Bool = false
    
    @State private var scrollOffset: CGFloat = 0
    
    init(context: NSManagedObjectContext, isSettingsPresented: Binding<Bool>) {
        _viewModel = State(wrappedValue: RestockViewModel(context: context))
        _isSettingsPresented = isSettingsPresented
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            //MARK: - BACKGROUND STYLES
            Color.colorWhiteSands
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading) {
                    
                    Text("Use this list to keep track of items that need replenishing")
                        .multilineTextAlignment(.leading)
                        .padding(.top, Constants.headerSpacing)
                        .padding(.bottom)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, Constants.wideMargin)
                    
                        //MARK: - RESTOCK LIST
                        LazyVStack(spacing: 0) {
                            
                            if !viewModel.restockItems.isEmpty {
                                
                                ForEach(Array(viewModel.sortedItems.enumerated()), id: \.element.id) { index, item in
                                    
                                    HStack(spacing: 0) {
                                        Spacer()
                                            .frame(width: 30)
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundColor(Color.colorSecondaryGrey)
                                        EditableItemView<RestockItem>(
                                            item: item,
                                            togglePacked: { viewModel.togglePacked(for: item)
                                                HapticsManager.shared.triggerLightImpact()
                                            },
                                            deleteItem: {
                                                viewModel.deleteItem(item)
                                            },
                                            isPickerFocused: $isPickerFocused,
                                            isRestockItem: true
                                        )
                                    }//:HSTACK
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color.colorSecondaryGrey),
                                        alignment: .bottom
                                    )
                                }//:FOREACH
                            }//:IF NOT EMPTY
                            
                            
                            //MARK: - ADD NEW ITEM
                            HStack(spacing: 0) {
                                Spacer()
                                    .frame(width: 30)
                                Rectangle()
                                    .frame(width: 1)
                                    .foregroundColor(Color.colorSecondaryGrey)
                                AddNewRestockItemView(
                                    viewModel: viewModel)
                                .offset(y: viewModel.restockItems.isEmpty ? -5 : 0)
                            }//:HSTACK
                            
                        }//:LAZYVSTACK
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .fill(Color.colorWhite)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                    
                }//:VSTACK
                .padding(.bottom, Constants.bodyPadding)
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
                title: "Restock",
                scrollOffset: $scrollOffset,
                scrollThreshold: -70
            )
            
            
            
        }//:ZSTACK
        .task {
            await viewModel.loadItems()
        }
        //MARK: - MENU
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSettingsPresented.toggle()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(Color.colorForestSecondary)
                        .accessibilityLabel("Settings")
                }
            }//:TOOL BAR ITEM
        }//:TOOLBAR
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

#if DEBUG
#Preview("Sample Data") {
    
    @Previewable @State var isSettingsPresented: Bool = false

    
    do {
        let previewStack = CoreDataStack.preview
        
        RestockItem.generateSampleItems(context: previewStack.context)
        
        try? previewStack.context.save()
        
        return NavigationStack {
            RestockView(context: previewStack.context, isSettingsPresented: $isSettingsPresented)
                .environment(\.managedObjectContext, previewStack.context)
            
        }
    }
}


#Preview("Empty") {
    
    @Previewable @State var isSettingsPresented: Bool = false
    let previewStack = CoreDataStack.preview
    
    NavigationStack {
        RestockView(context: previewStack.context, isSettingsPresented: $isSettingsPresented)
            .environment(\.managedObjectContext, previewStack.context)
        
    }
}

#endif

