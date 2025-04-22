//
//  ProgressIndicatorView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

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
#if DEBUG
#Preview {
    
    @Previewable @State var isNewListQuizPresented: Bool = true
    @Previewable @State var isStepOne: Bool = true
    
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let context = PersistenceController.preview.container.viewContext
    
    
    NavigationStack {
        QuizView(viewModel: QuizViewModel(context: context), isNewListQuizPresented: $isNewListQuizPresented, isStepOne: $isStepOne, navigateToListView: $navigateToListView, currentPackingList: $currentPackingList, packingListCount: 3)
            .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
    }
}
#endif
