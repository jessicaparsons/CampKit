//
//  QuizPageOneView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct QuizPageOneView: View {
    
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Bindable var viewModel: QuizViewModel
    @State private var isElevationPopoverPresented: Bool = true
    @FocusState var isFocused: Bool
    @Binding var isElevationAdded: Bool
    @Binding var isLocationSearchOpen: Bool
    @Binding var isStepOne: Bool
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)
    
    var barCount: Int {
        Int(viewModel.elevation / 500)
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
                    HStack {
                        TextField("Camping List", text: $viewModel.listTitle)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                        if isFocused {
                            Button {
                                isFocused = false
                            } label: {
                                Text("Done")
                            }
                            .padding(.trailing)
                        }
                    }//:HSTACK
                    .overlay {
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.colorSteel, lineWidth: 1)
                    }
                    .focused($isFocused)
                }//:VSTACK
                
                participantChoices
                
                locationSearch
                
                elevationChanger
                
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
                    .padding(.bottom, Constants.quizPadding)
                    
                }//:VSTACK
                
            }//:VSTACK
            .padding(.horizontal, Constants.horizontalPadding)
            .onTapGesture {
                hideKeyboard()
            }
        }//:ZSTACK
        
    }//:BODY
    
    //MARK: - WHO'S GOING
    private var participantChoices: some View {
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
                    title: "Adults",
                    isSelected: viewModel.selectedFilters.contains(ChoiceOptions.adults),
                    onTap: { viewModel.toggleSelection(ChoiceOptions.adults) })
                CardButtonView(emoji: "🧸",
                               title: "Kids",
                               isSelected: viewModel.selectedFilters.contains(ChoiceOptions.kids),
                               onTap: { viewModel.toggleSelection(ChoiceOptions.kids) })
                CardButtonView(emoji: "🐶",
                               title: "Pets",
                               isSelected: viewModel.selectedFilters.contains(ChoiceOptions.pets),
                               onTap: { viewModel.toggleSelection(ChoiceOptions.pets) })
            }
            
        }
    }//:WHOISGOING
    
    //MARK: - LOCATION SEARCH
    private var locationSearch: some View {
        Group {
            HStack {
                Text("Where you headed? (optional)")
                    .font(.footnote)
                    .fontWeight(.bold)
                Spacer()
            }
            ZStack {
                HStack {
                    if let name = viewModel.locationName {
                        if let address = viewModel.locationAddress {
                            Text("\(name), \(address)")
                        } else {
                            Text(name)
                        }
                    } else {
                        Text("Search...")
                            .foregroundColor(Color(UIColor.placeholderText))
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
    }//:WHEREYOUHEADED
    
    //MARK: - MODIFY ELEVATOIN
    
    private var elevationChanger: some View {
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
                
                Slider(value: $viewModel.elevation, in: 0...10000, step: 100)
                    .tint(Color.colorNeon)
                    .onChange(of: viewModel.elevation) {
                        HapticsManager.shared.triggerLightImpact()
                        if viewModel.elevation > 0 {
                            isElevationAdded = true
                        } else {
                            isElevationAdded = false
                        }
                    }
                
            }//:ZSTACK
            
            HStack {
                Spacer()
                Text("+ \(Int(viewModel.elevation)) ft")
                Spacer()
            }//HSTACK
                
            
        }//:VSTACK
    }//:ELEVATIONCHANGER
    
}
#if DEBUG
#Preview {
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var isLocationSearchOpen: Bool = false
    @Previewable @State var isElevationAdded: Bool = true
    
    let previewStack = CoreDataStack.preview
    
    NavigationView {
        ScrollView {
            QuizPageOneView(viewModel: QuizViewModel(context: previewStack.context), isElevationAdded: $isElevationAdded, isLocationSearchOpen: $isLocationSearchOpen, isStepOne: $isStepOne)
                .environment(\.managedObjectContext, previewStack.context)
                .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
        }
    }
}
#endif
