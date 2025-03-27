//
//  BarView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI
import SwiftData

struct ElevationBarView: View {
    
    var height: Double
    @State private var isAnimating: Bool = false
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.colorTan, Color.colorLilac]), startPoint: .top, endPoint: .bottom))
                .frame(width: 15, height: CGFloat(height)) // Dynamic height
                .scaleEffect(y: isAnimating ? 1 : 0, anchor: .bottom)
        }
        .onAppear {
            withAnimation(.bouncy(duration: 0.4)) {
                self.isAnimating = true
            }
        }
}
    }
        
  
#Preview("QuizView") {
    
    @Previewable @State var isNewListQuizShowing: Bool = true
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizView(viewModel: QuizViewModel(modelContext: container.mainContext), isNewListQuizShowing: $isNewListQuizShowing, isStepOne: $isStepOne,    navigateToListView: $navigateToListView, currentPackingList: $currentPackingList)
}


#Preview {
    ElevationBarView(height: 30)
}
