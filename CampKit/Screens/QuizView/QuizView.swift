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
    @State var viewModel: QuizViewModel
    @State var weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient())
    @Binding var isNewListQuizShowing: Bool
    @Binding var isStepOne: Bool
    @Binding var navigateToListView: Bool
    @Binding var currentPackingList: PackingList?
    @State private var location: String = ""
    @State private var elevation: Double = 0.0
    @State private var isLocationSearchOpen: Bool = false
    @State private var listName: String = ""
    @State private var isElevationAdded: Bool = false
    
    var body: some View {
        
        ZStack {
            VStack {
                
                //QUIZ PAGES
                ZStack {
                    ScrollView {
                        if isStepOne {
                            QuizPageOneView(viewModel: viewModel, weatherViewModel: weatherViewModel, isElevationAdded: $isElevationAdded, location: $location, elevation: $elevation, isLocationSearchOpen: $isLocationSearchOpen, isStepOne: $isStepOne, listName: $listName)
                                .transition(.move(edge: .leading))
                        } else {
                            QuizPageTwoView(viewModel: viewModel, isStepOne: $isStepOne, location: $location, elevation: $elevation, isElevationAdded: $isElevationAdded)
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
                                    viewModel.listTitle = listName
                                    
                                    if location != "" {
                                        viewModel.locationName = location
                                    }
                                    
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
                    LocationSearchView(location: $location, isLocationSearchOpen: $isLocationSearchOpen)
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
        location = ""
        elevation = 0.0
        isLocationSearchOpen = false
        listName = ""
        isElevationAdded = false
        
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
