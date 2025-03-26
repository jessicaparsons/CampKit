//
//  QuizView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import SwiftData

struct QuizView: View {

    @State var viewModel: QuizViewModel
    @State var weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient())
    @Binding var isNewListQuizShowing: Bool
    @Binding var isStepOne: Bool
    @State private var location: String = ""
    @State private var elevation: Double = 0.0
    @State private var isLocationSearchOpen: Bool = false
    @State private var listName: String = ""
    
    var body: some View {
        VStack {
            ZStack {
                ScrollView {
                    if isStepOne {
                        QuizPageOneView(viewModel: viewModel, weatherViewModel: weatherViewModel, location: $location, elevation: $elevation, isLocationSearchOpen: $isLocationSearchOpen, isStepOne: $isStepOne, listName: $listName)
                            .transition(.move(edge: .leading))
                    } else {
                        QuizPageTwoView(viewModel: viewModel, isStepOne: $isStepOne, location: $location, elevation: $elevation)
                            .transition(.move(edge: .trailing))
                    }
                }
            }//:ZSTACK
            
            Spacer()
            
            VStack {
                ProgressIndicatorView(isStepOne: $isStepOne)
                    .padding(.bottom, Constants.verticalSpacing)
                
                HStack {
                    //Show back button only on step 2
                    if !isStepOne {
                        Button(action: {
                            isStepOne = true
                        }) {
                            Text("Back")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BigButtonWide())
                    }

                    Button(action: {
                        if isStepOne {
                            isStepOne = false
                        } else {
                            viewModel.listTitle = listName
                            viewModel.locationName = location
                            viewModel.createPackingList()
                            isNewListQuizShowing = false
                        }
                    }) {
                        Text(isStepOne ? "Next" : "Create List")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BigButtonWide())
                }
            }
            .padding()
            .padding(.bottom, 20)
        }//VSTACK
        .fullScreenCover(isPresented: $isLocationSearchOpen, content: {
            
            //MARK: - LOCATION SEARCH
            
            VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                LocationSearchView(location: $location, isLocationSearchOpen: $isLocationSearchOpen)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut(duration: 0.3), value: isLocationSearchOpen)
            }
        })
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
        }
        .onDisappear {
            isStepOne = true
        }
    }//:BODY
}


#Preview {
    
    @Previewable @State var isNewListQuizShowing: Bool = true
    @Previewable @State var isStepOne: Bool = true
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizView(viewModel: QuizViewModel(modelContext: container.mainContext), isNewListQuizShowing: $isNewListQuizShowing, isStepOne: $isStepOne)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient()))
}
