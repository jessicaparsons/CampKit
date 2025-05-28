//
//  BarView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI

struct ElevationBarView: View {
    
    var height: Double
    @State private var isAnimating: Bool = false
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.colorSecondaryGrey, Color.colorNeon]), startPoint: .top, endPoint: .bottom))
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
        
#if DEBUG
#Preview("QuizView") {
    
    @Previewable @State var isNewListQuizPresented: Bool = true
    @Previewable @State var currentStep: Int = 1
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    
    let context = CoreDataStack.shared.context
        
    QuizView(
        viewModel: QuizViewModel(context: context),
        isNewListQuizPresented: $isNewListQuizPresented,
        currentStep: $currentStep,
        navigateToListView: $navigateToListView,
        currentPackingList: $currentPackingList,
        packingListCount: 3)
        .environment(\.managedObjectContext, context)
        .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
}


#Preview {
    ElevationBarView(height: 30)
}
#endif
