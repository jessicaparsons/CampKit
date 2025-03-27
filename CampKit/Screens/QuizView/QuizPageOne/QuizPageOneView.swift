//
//  QuizPageOneView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI
import SwiftData

struct QuizPageOneView: View {
    
    @State var viewModel: QuizViewModel
    @State var weatherViewModel: WeatherViewModel
    @State private var isShowingElevationPopover: Bool = true
    @Binding var isElevationAdded: Bool
    @Binding var location: String
    @Binding var elevation: Double
    @Binding var isLocationSearchOpen: Bool
    @Binding var isStepOne: Bool
    @Binding var listName: String
    @FocusState private var isTextFieldFocused: Bool
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)
    
    var barCount: Int {
        Int(elevation / 500)
    } // Number of bars (each 550ft adds 1 bar)
    
    
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .center, spacing: Constants.cardSpacing) {
                
                //MARK: - TITLE
                VStack(alignment: .center) {
                    Text("Create a new list")
                        .font(.title)
                        .fontWeight(.bold)
                }//:VSTACK
                
                //MARK: - NAME THE LIST
                VStack(alignment: .leading) {
                    Text("Name your list")
                        .font(.footnote)
                        .fontWeight(.bold)
                    TextField("Camping List", text: $listName)
                        .focused($isTextFieldFocused)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(Color.colorSteel, lineWidth: 1)
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true  // Helps focus the TextField when this view appears to avoid delay bug
                            }
                        }
                }//:VSTACK
                
                //MARK: - WHO'S GOING?
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    
                    HStack(alignment:.bottom) {
                        Text("Who's going?")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: columns, alignment: .center) {
                        CardButtonView(
                            emoji: "👨‍🦰",
                            title: ChoiceOptions.adults,
                            isSelected: viewModel.selectedFilters.contains(ChoiceOptions.adults),
                            onTap: { viewModel.toggleSelection(ChoiceOptions.adults) })
                        CardButtonView(emoji: "🧸",
                                       title: ChoiceOptions.kids,
                                       isSelected: viewModel.selectedFilters.contains(ChoiceOptions.kids),
                                       onTap: { viewModel.toggleSelection(ChoiceOptions.kids) })
                        CardButtonView(emoji: "🐶",
                                       title: ChoiceOptions.dogs,
                                       isSelected: viewModel.selectedFilters.contains(ChoiceOptions.dogs),
                                       onTap: { viewModel.toggleSelection(ChoiceOptions.dogs) })
                    }
                    
                }
                
                
                //MARK: - WHERE YOU HEADED?
                Group {
                    HStack {
                        Text("Where you headed? (optional)")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    ZStack {
                        HStack {
                            if location == "" {
                                Text("Search...")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(location)
                            }
                            Spacer()
                            Image(systemName: "magnifyingglass")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .overlay {
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(Color.colorSteel, lineWidth: 1)
                        }
                    }//:ZSTACK
                    .onTapGesture {
                        withAnimation {
                            isLocationSearchOpen.toggle()
                        }
                    }
                }//:GROUP
                
                
                //MARK: - MODIFY ELEVATION
                
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading, spacing: Constants.lineSpacing) {
                        Text("Modify elevation (optional)")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Text("Add additional elevation for a more accurate weather prediction")
                            .font(.caption2)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                    }//:VSTACK
                    
                    
                    ZStack(alignment: .bottomLeading) {
                        
                        // Bars grow along this axis
                        HStack(alignment: .bottom, spacing: 2) {
                            ForEach(0..<barCount, id: \.self) { index in
                                ElevationBarView(height: Double(index + 1) * 2) // Height increases with index
                            }
                        }
                        .frame(height: 50, alignment: .bottom)
                        .offset(x: 15, y: -18)
                        
                        Slider(value: $elevation, in: 0...10000, step: 100)
                            .tint(Color.colorNeon)
                            .onChange(of: elevation) {
                                HapticsManager.shared.triggerLightImpact()
                                if elevation > 0 {
                                    isElevationAdded = true
                                }
                            }
                        
                    }//:ZSTACK
                    
                    HStack {
                        Spacer()
                        Text("+ \(Int(elevation)) ft")
                        Spacer()
                    }//HSTACK
                        
                    
                }//:VSTACK
                
                
                //MARK: - ACTIVITIES
                
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    HStack {
                        Text("Activities")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.activities
                    )
                    Spacer()
                    
                }//:VSTACK
                
            }//:VSTACK
            .padding(.horizontal, Constants.horizontalPadding)
            .onTapGesture {
                hideKeyboard()
            }
        }//:ZSTACK
        
    }//:BODY
    
}

#Preview {
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var location: String = "Paris"
    @Previewable @State var elevation: Double = 0.0
    @Previewable @State var isLocationSearchOpen: Bool = false
    @Previewable @State var listName: String = ""
    @Previewable @State var isElevationAdded: Bool = true
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    NavigationView {
        QuizPageOneView(viewModel: QuizViewModel(modelContext: container.mainContext), weatherViewModel: WeatherViewModel(weatherFetcher: WeatherAPIClient()), isElevationAdded: $isElevationAdded, location: $location, elevation: $elevation, isLocationSearchOpen: $isLocationSearchOpen, isStepOne: $isStepOne, listName: $listName)
    }
}
