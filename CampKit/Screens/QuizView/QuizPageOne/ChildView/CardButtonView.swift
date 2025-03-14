//
//  CardButtonView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI
import SwiftData

struct CardButtonView: View {
    
    @Bindable var viewModel: QuizViewModel
    let emoji: String
    let title: String
    @State var isSelected: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(emoji)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(isSelected ? Color.colorTan : Color.clear)
                    .stroke(isSelected ? Color.clear : Color.colorSteel, lineWidth: 1)
                
            )
            .onTapGesture {
                isSelected.toggle()
                viewModel.toggleParticipant(title)
                HapticsManager.shared.triggerLightImpact()
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .padding(.top, 2)
            
        }//:VSTACK
    }//:BODY
    
}


#Preview("Quiz View") {
    
    @Previewable @State var isNewListQuizShowing: Bool = true
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var location: String = "Paris"
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizView(viewModel: QuizViewModel(modelContext: container.mainContext), isNewListQuizShowing: $isNewListQuizShowing, isStepOne: $isStepOne, location: $location)
}


#Preview {
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    CardButtonView(viewModel: QuizViewModel(modelContext: container.mainContext), emoji: "🧍‍♂️", title: "Adults")
}
