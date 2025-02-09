//
//  QuizPageOneView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI
import SwiftData

struct QuizPageOneView: View {
    
    @ObservedObject var viewModel: QuizViewModel
    @Binding var location: String
    @State private var elevation: Double = 0
    @Binding var isStepOne: Bool
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)

    var barCount: Int {
        Int(elevation / 500)
    } // Number of bars (each 550ft adds 1 bar)
    
    
    
    var body: some View {
        
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
                        CardButtonView(emoji: "👨‍🦰", title: "Adults")
                        CardButtonView(emoji: "🧸", title: "Kids")
                        CardButtonView(emoji: "🐶", title: "Dogs")
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
                    HStack {
                        TextField("Search...", text: $location)
                        Image(systemName: "magnifyingglass")
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .overlay {
                        RoundedRectangle(cornerRadius: Constants.cornerRadius)
                            .stroke(Color.colorSteel, lineWidth: 1)
                    }
                }
                
                //MARK: - ADD ELEVATION
                
                VStack {
                    HStack {
                        Text("Add elevation (optional)")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    
                    ZStack(alignment: .bottomLeading) {
                        
                        // Bars grow along this axis
                        HStack(alignment: .bottom, spacing: 2) {
                            ForEach(0..<barCount, id: \.self) { index in
                                BarView(height: Double(index + 1) * 2) // Height increases with index
                            }
                        }
                        .frame(height: 50, alignment: .bottom)
                        .offset(x: 15, y: -18)
                        
                        Slider(value: $elevation, in: 0...14000, step: 100)
                            .tint(Color.colorNeon)
                            .onChange(of: elevation) {
                                HapticsManager.shared.triggerLightImpact()
                            }

                    }

                    Text("\(Int(elevation)) ft")
                    
                }//:VSTACK
                
                
                //MARK: - ACTIVITIES
                
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    HStack {
                        Text("Activities")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ChipSectionView(choices: $viewModel.activityArray)
                    
                }//:VSTACK
                
            }//:VSTACK
            .padding(.horizontal, Constants.horizontalPadding)
            

    }//:BODY
    
}

#Preview {
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var location: String = "Paris"

    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    QuizPageOneView(viewModel: QuizViewModel(modelContext: container.mainContext), location: $location, isStepOne: $isStepOne)
}
