//
//  ProgressIndicatorView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI
import SwiftData

struct ProgressIndicatorView: View {
    
    @Binding var isStepOne: Bool
    @State private var isAnimating: Bool = false
    @State private var leftOrRight: Alignment = .leading
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.colorSteel)
                .frame(height: 7)
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.colorNeon)
                    .frame(width: (UIScreen.main.bounds.width / 2) - 15, height: 7)
            }
            .frame(maxWidth: .infinity, alignment: leftOrRight)
            
        }//:ZSTACK
        .onChange(of: isStepOne) {
            withAnimation(.bouncy(duration: 0.4)) {
                leftOrRight = isStepOne ? .leading : .trailing
            }
        }
    }
}

#Preview("QuizView") {
    @Previewable @State var isNewListQuizShowing: Bool = true
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var location: String = "Paris"
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizView(viewModel: QuizViewModel(modelContext: container.mainContext), isNewListQuizShowing: $isNewListQuizShowing, isStepOne: $isStepOne,     navigateToListView: $navigateToListView, currentPackingList: $currentPackingList, packingListCount: 3
)
}


//#Preview {
//    
//    @Previewable @State var isStepOne: Bool = true
//    @Previewable @State var leftOrRight: Alignment = .leading
//    
//    ProgressIndicatorView(isStepOne: $isStepOne, leftOrRight: leftOrRight)
//}
