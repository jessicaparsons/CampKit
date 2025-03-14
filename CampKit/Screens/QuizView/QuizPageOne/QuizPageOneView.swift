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
    @State private var location: String = ""
    @State private var elevation: Double = 0
    @State private var isLocationSearchOpen: Bool = false
    @Binding var isStepOne: Bool
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
                    Text("Bop it, shake it, customize it.")
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
                        CardButtonView(viewModel: viewModel, emoji: "👨‍🦰", title: ChoiceOptions.adults)
                        CardButtonView(viewModel: viewModel, emoji: "🧸", title: ChoiceOptions.kids)
                        CardButtonView(viewModel: viewModel, emoji: "🐶", title: ChoiceOptions.dogs)
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
                
                
                //MARK: - ADD ELEVATION
                
                VStack {
                    HStack {
                        Text("Add Elevation Compensation (optional)")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    
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
                            }
                        
                    }
                    
                    Text("+ \(Int(elevation)) ft")
                    
                }//:VSTACK
                
                
                //MARK: - ACTIVITIES
                
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    HStack {
                        Text("Activities")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ChipSectionView(choices: $viewModel.activityChoices)
                    
                }//:VSTACK
                
            }//:VSTACK
            .padding(.horizontal, Constants.horizontalPadding)
            
            //MARK: - LOCATION SEARCH
            
            VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                LocationSearchView(location: $location, isLocationSearchOpen: $isLocationSearchOpen)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .offset(x: isLocationSearchOpen ? 0 : UIScreen.main.bounds.width) // Slide in from right
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut(duration: 0.3), value: isLocationSearchOpen)
            }
            
            
        }//:ZSTACK
        
    }//:BODY
    
}

#Preview {
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var location: String = "Paris"
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    NavigationView {
        QuizPageOneView(viewModel: QuizViewModel(modelContext: container.mainContext), isStepOne: $isStepOne)
    }
}
