//
//  QuizView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import PhotosUI

struct QuizView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Bindable var viewModel: QuizViewModel
    
    @Binding var isNewListQuizPresented: Bool
    @Binding var currentStep: Int
    @Binding var navigateToListView: Bool
    @Binding var currentPackingList: PackingList?
    let packingListCount: Int

    @State private var isLocationSearchOpen: Bool = false
    @State private var isElevationAdded: Bool = false
    
    //PHOTO PICKER
    @State private var isPhotoPickerPresented: Bool = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        
        ZStack {
            VStack {
                
                //QUIZ PAGES
                ZStack {
                    ScrollView {
                        if currentStep == 1 {
                            QuizPageOneView(
                                viewModel: viewModel,
                                isElevationAdded: $isElevationAdded
                            )
                           
                        } else if currentStep == 2 {
                            QuizPageTwoView(
                                viewModel: viewModel,
                                isElevationAdded: $isElevationAdded
                            )
                            
                        } else {
                            QuizPageThreeView(viewModel: viewModel)
                                
                        }
                    }
                    .scrollIndicators(.hidden)
                }//:ZSTACK
                .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedPhoto, matching: .images)
                .onChange(of: selectedPhoto) {
                    guard let selectedPhoto else { return }

                    Task {
                        if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            viewModel.setGalleryPhoto(image)
                            viewModel.createPackingList()
                            HapticsManager.shared.triggerSuccess()
                            
                            if let packingList = viewModel.currentPackingList {
                                currentPackingList = packingList
                                navigateToListView = true
                                isNewListQuizPresented = false
                            }
                        }
                    }
                }
                
                
            }//VSTACK
            
            //MARK: - BUTTONS
            .overlay(
                VStack {
                    Spacer()
                    VStack {
                        ProgressIndicatorView(currentStep: $currentStep)
                            .padding(.bottom, Constants.verticalSpacing)
                        
                        HStack {
                            //MARK: - BACK BUTTON
                            
                            Button(action: {
                                if currentStep == 1 {
                                    dismiss()
                                } else {
                                    currentStep -= 1
                                }
                            }) {
                                Text(currentStep == 1 ? "" : "Back")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(BigButtonWide())
                            .opacity(currentStep == 1 ? 0 : 1)
                            .animation(.interactiveSpring, value: currentStep)
                            .accessibilityHint("Back")
                            
                            //MARK: - NEXT / CREATE LIST BUTTON
                            Button(action: {
                                if currentStep < 3 {
                                    currentStep += 1
                                } else {
                                    
                                    viewModel.createPackingList()
                                    HapticsManager.shared.triggerSuccess()
                                    
                                    if let packingList = viewModel.currentPackingList {
                                        currentPackingList = packingList
                                        navigateToListView = true
                                        isNewListQuizPresented = false
                                    }
                                    resetQuiz()
                                }
                            }) {
                                Text(currentStep < 3 ? "Next" : "Create List")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(BigButtonWide())
                            .accessibilityHint("Next / Create List")
                        }//:HSTACK
                        .padding(.bottom)
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.colorWhite)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -4)
                    )
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
            )//:OVERLAY
            
            //MARK: - MENU
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isNewListQuizPresented = false
                        currentStep = 1
                        resetQuiz()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .tint(Color.primary)
                            .accessibilityLabel("Exit")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    
                    if currentStep == 3 {
                        
                        Button {
                            isPhotoPickerPresented.toggle()
                        } label: {
                            Image(systemName: "camera")
                                .foregroundStyle(Color.primary)
                                .accessibilityLabel("Open phone gallery")
                                
                        }
                        
                    } else {
                        
                        Button {
                            resetQuiz()
                        } label: {
                            Text("Clear All")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .tint(Color.primary)
                        }
                    }
                }
            }
            .toolbarBackground(Color.colorWhiteBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onDisappear {
                currentStep = 1
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
        viewModel.startDate = nil
        viewModel.endDate = nil
        weatherViewModel.isNoLocationFoundMessagePresented = false
        
        viewModel.resetSelections()
    }
}

#if DEBUG
#Preview {
    
    @Previewable @State var isNewListQuizPresented: Bool = true
    @Previewable @State var currentStep: Int = 1
    
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let context = CoreDataStack.preview.context
    
    NavigationStack {
        QuizView(
            viewModel: QuizViewModel(context: context),
            isNewListQuizPresented: $isNewListQuizPresented,
            currentStep: $currentStep,
            navigateToListView: $navigateToListView,
            currentPackingList: $currentPackingList,
            packingListCount: 3)
            .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
    }
}
#endif
