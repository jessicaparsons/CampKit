//
//  CardButtonView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct CardButtonView: View {
    
    let emoji: String
    let title: String
    var isSelected: Bool
    let onTap: () -> Void
    
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
                    .stroke(isSelected ? Color.colorSage : Color.colorSteel, lineWidth: 1)
                
            )
            .onTapGesture {
                onTap()
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

#if DEBUG
#Preview("Quiz View") {
    
    @Previewable @State var isNewListQuizPresented: Bool = true
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var location: String = "Paris"
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let previewContext = PersistenceController.preview.container.viewContext

    QuizView(
        viewModel: QuizViewModel(context: previewContext),
        isNewListQuizPresented: $isNewListQuizPresented,
        isStepOne: $isStepOne,
        navigateToListView: $navigateToListView,
        currentPackingList: $currentPackingList,
        packingListCount: 3
    )
    .environment(\.managedObjectContext, previewContext)
}
#endif

