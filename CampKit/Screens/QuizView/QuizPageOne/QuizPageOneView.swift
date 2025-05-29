//
//  QuizPageOneView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct QuizPageOneView: View {
    
    @Environment(WeatherViewModel.self) private var weatherViewModel
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: QuizViewModel
    @State private var isElevationPopoverPresented: Bool = true
    @FocusState var isFocused: Bool
    @Binding var isElevationAdded: Bool
    @State private var isLocationSearchPresented: Bool = false
    @State private var showStepper: Bool = false
    @State private var isCalendarPresented: Bool = false
    
    @State private var tempStartDate: Date? = nil
    @State private var tempEndDate: Date? = nil
    @State private var formattedDate: String = "Select Dates"
    
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)
    
    var barCount: Int {
        Int(viewModel.elevation / 500)
    } // Number of bars (each 550ft adds 1 bar)
    
    var participantsSelected: Bool {
        !viewModel.selectedFilters.isDisjoint(with: [ChoiceOptions.adults, ChoiceOptions.kids, ChoiceOptions.pets])
    }
    
    var body: some View {
        
        ZStack {
            VStack(spacing: Constants.cardSpacing) {
                
                //MARK: - TITLE
                VStack(alignment: .center) {
                    Text("Create a new list")
                        .font(.title)
                        .fontWeight(.bold)
                }//:VSTACK
                .padding(.top, Constants.largePadding)
                
                //MARK: - NAME THE LIST
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
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
                            .stroke(Color.colorToggleOff, lineWidth: 1)
                    }
                    .focused($isFocused)
                
                
               
                    
                participantChoices
                
                datePicker
                
                }//:VSTACK
                
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
        .background(Color.colorWhiteBackground)
        
    }//:BODY
    
    
    //MARK: - WHEN ARE YOU GOING
    
    private var datePicker: some View {
        VStack(alignment: .leading, spacing: Constants.cardSpacing) {
            Text("When are you going? (optional)")
                .font(.footnote)
                .fontWeight(.bold)
            
            Button(action: {
                tempStartDate = viewModel.startDate
                tempEndDate = viewModel.endDate
                isCalendarPresented = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                        
                    Text(formattedDate)
                        .font(.footnote)
                        .fontWeight(.medium)
                }//:HSTACK
                .foregroundColor(Color.primary)
                .padding(.vertical, Constants.verticalSpacing)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                                .stroke(Color.colorToggleOff, lineWidth: 1)
                        )
                )
            }
            .sheet(isPresented: $isCalendarPresented) {
                DatePickerView(
                    startDate: $tempStartDate,
                    endDate: $tempEndDate
                ) {
                    viewModel.startDate = tempStartDate
                    viewModel.endDate = tempEndDate
                    formattedDate = Date.formattedRange(from: viewModel.startDate, to: viewModel.endDate)
                }
            }
        }//:VSTACK
        .onChange(of: viewModel.startDate) {
            if viewModel.startDate == nil {
                tempStartDate = nil
                tempEndDate = nil
                formattedDate = "Select Dates"
            }
        }
    }
    
    //MARK: - WHO'S GOING
    private var participantChoices: some View {
        VStack(alignment: .leading, spacing: Constants.cardSpacing) {
            
            HStack(alignment:.bottom) {
                Text("Who's going?")
                    .font(.footnote)
                    .fontWeight(.bold)
                Spacer()
            }
            VStack {
                LazyVGrid(columns: columns, alignment: .center) {
                    CardButtonView(
                        emoji: "👨‍🦰",
                        title: "Adults",
                        isSelected: viewModel.selectedFilters.contains(ChoiceOptions.adults),
                        onTap: {
                            viewModel.toggleSelection(ChoiceOptions.adults)
                        })
                    CardButtonView(emoji: "🧸",
                                   title: "Kids",
                                   isSelected: viewModel.selectedFilters.contains(ChoiceOptions.kids),
                                   onTap: {
                        viewModel.toggleSelection(ChoiceOptions.kids)
                    })
                    CardButtonView(emoji: "🐶",
                                   title: "Pets",
                                   isSelected: viewModel.selectedFilters.contains(ChoiceOptions.pets),
                                   onTap: {
                        viewModel.toggleSelection(ChoiceOptions.pets)
                    })
                }//:LAZYGRID
                    
            }//:VSTACK
            
            
        }//:VSTACK
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
                        .stroke(Color.colorToggleOff, lineWidth: 1)
                }
            }//:ZSTACK
            .background(Color.white.opacity(0.001))
            .onTapGesture {
                withAnimation {
                    isLocationSearchPresented.toggle()
                }
            }
            //MARK: - LOCATION SEARCH
            .fullScreenCover(isPresented: $isLocationSearchPresented, content: {
                
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    LocationSearchView(
                        locationName: $viewModel.locationName,
                        locationAddress: $viewModel.locationAddress)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .transition(.move(edge: .trailing))
                }
            })
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
    @Previewable @State var isElevationAdded: Bool = true
    
    let previewStack = CoreDataStack.preview
    
    NavigationView {
        ScrollView {
            QuizPageOneView(
                viewModel: QuizViewModel(context: previewStack.context),
                isElevationAdded: $isElevationAdded,
            )
                .environment(\.managedObjectContext, previewStack.context)
                .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
        }
    }
}
#endif
