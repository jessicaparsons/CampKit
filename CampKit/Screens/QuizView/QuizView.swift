//
//  QuizView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI

struct QuizView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Bindable var viewModel: QuizViewModel
    @Binding var isNewListQuizPresented: Bool
    @Binding var isStepOne: Bool
    @Binding var navigateToListView: Bool
    @Binding var currentPackingList: PackingList?
    let packingListCount: Int

    @State private var isLocationSearchOpen: Bool = false
    @State private var isElevationAdded: Bool = false
    
    var body: some View {
        
        ZStack {
            VStack {
                
                //QUIZ PAGES
                ZStack {
                    ScrollView {
                        if isStepOne {
                            QuizPageOneView(
                                viewModel: viewModel,
                                isElevationAdded: $isElevationAdded,
                                isLocationSearchOpen: $isLocationSearchOpen,
                                isStepOne: $isStepOne)
                                .transition(.move(edge: .leading))
                        } else {
                            QuizPageTwoView(
                                viewModel: viewModel,
                                isStepOne: $isStepOne,
                                isElevationAdded: $isElevationAdded)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .scrollIndicators(.hidden)
                }//:ZSTACK
                
                
            }//VSTACK
            
            //MARK: - BUTTONS
            .overlay(
                VStack {
                    Spacer()
                    VStack {
                        ProgressIndicatorView(isStepOne: $isStepOne)
                            .padding(.bottom, Constants.verticalSpacing)
                        
                        HStack {
                            //MARK: - BLANK LIST / BACK BUTTON
                            
                            Button(action: {
                                if !isStepOne {
                                    isStepOne = true
                                } else {
                                    viewModel.createBlankPackingList()
                                    
                                    if let packingList = viewModel.currentPackingList {
                                        currentPackingList = packingList
                                        navigateToListView = true
                                        isNewListQuizPresented = false
                                    }
                                }
                                    
                            }) {
                                Text(isStepOne ? "New Blank List" : "Back")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(BigButtonWide())
                            
                            //MARK: - NEXT / CREATE LIST BUTTON
                            Button(action: {
                                if isStepOne {
                                    isStepOne = false
                                } else {
                                    
                                    viewModel.createPackingList()
                                    
                                    if let packingList = viewModel.currentPackingList {
                                        currentPackingList = packingList
                                        navigateToListView = true
                                        isNewListQuizPresented = false
                                    }
                                }
                            }) {
                                Text(isStepOne ? "Next" : "Create List")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(BigButtonWide())
                        }//:HSTACK
                        .padding(.bottom)
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.colorWhite)
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: -4)
                    )
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
            )//:OVERLAY
            
            //MARK: - LOCATION SEARCH
            .fullScreenCover(isPresented: $isLocationSearchOpen, content: {
                
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    LocationSearchView(
                        isLocationSearchOpen: $isLocationSearchOpen,
                        locationName: $viewModel.locationName,
                        locationAddress: $viewModel.locationAddress)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut(duration: 0.3), value: isLocationSearchOpen)
                }
            })
            //MARK: - MENU
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isNewListQuizPresented = false
                        isStepOne = true
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .tint(Color.accent)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        resetQuiz()
                    } label: {
                        Text("Clear All")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .tint(Color.accent)
                    }
                }
            }
            .toolbarBackground(Color.colorWhiteBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onDisappear {
                isStepOne = true
            }
            .ignoresSafeArea(.keyboard)
        }//:ZSTACK
        .ignoresSafeArea(edges: .bottom)
        
    }//:BODY
    
    private func resetQuiz() {
        viewModel.locationName = nil
        viewModel.locationAddress = nil
        viewModel.elevation = 0.0
        isLocationSearchOpen = false
        viewModel.listTitle = ""
        isElevationAdded = false
        weatherViewModel.isNoLocationFoundMessagePresented = false
        
        viewModel.resetSelections()
    }
}

#if DEBUG
#Preview {
    
    @Previewable @State var isNewListQuizPresented: Bool = true
    @Previewable @State var isStepOne: Bool = true
    
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let context = CoreDataStack.shared.context
    
    NavigationStack {
        QuizView(viewModel: QuizViewModel(context: context), isNewListQuizPresented: $isNewListQuizPresented, isStepOne: $isStepOne, navigateToListView: $navigateToListView, currentPackingList: $currentPackingList, packingListCount: 3)
            .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
    }
}
#endif
