//
//  QuizView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import SwiftData

struct QuizView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @State var viewModel: QuizViewModel
    @Binding var isNewListQuizShowing: Bool
    @Binding var isStepOne: Bool
    @Binding var navigateToListView: Bool
    @Binding var currentPackingList: PackingList?

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
                                        isNewListQuizShowing = false
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
                                        isNewListQuizShowing = false
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
                        isNewListQuizShowing = false
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
        weatherViewModel.isShowingNoLocationFoundMessage = false
        
        viewModel.resetSelections()
    }
}


#Preview {
    
    @Previewable @State var isNewListQuizShowing: Bool = true
    @Previewable @State var isStepOne: Bool = true
    
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    NavigationStack {
        QuizView(viewModel: QuizViewModel(modelContext: container.mainContext), isNewListQuizShowing: $isNewListQuizShowing, isStepOne: $isStepOne, navigateToListView: $navigateToListView, currentPackingList: $currentPackingList)
            .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
    }
}
