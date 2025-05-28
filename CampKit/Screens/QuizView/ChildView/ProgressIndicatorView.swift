//
//  ProgressIndicatorView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/6/25.
//

import SwiftUI

struct ProgressIndicatorView: View {
    
    @Binding var currentStep: Int
    
    @State private var leftOrRight: Alignment = .leading
    @State private var fillWidth: CGFloat = UIScreen.main.bounds.width / 3 - 20
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.colorToggleOff)
                .frame(height: 7)

            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.colorNeon)
                    .frame(width: fillWidth, height: 7)
            }
            .frame(maxWidth: .infinity, alignment: leftOrRight)
        }
        .onChange(of: currentStep) { updatePosition() }
        .onAppear { updatePosition() }
    }

    private func updatePosition() {
        withAnimation(.bouncy(duration: 0.4)) {
            switch currentStep {
            case 1: leftOrRight = .leading
            case 2: leftOrRight = .center
            default: leftOrRight = .trailing
            }
        }
    }
}
#if DEBUG
#Preview {
    
    @Previewable @State var isNewListQuizPresented: Bool = true
    @Previewable @State var currentStep: Int = 1
    
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList?
    
    let previewStack = CoreDataStack.preview
    
    
    NavigationStack {
        QuizView(
            viewModel: QuizViewModel(context: previewStack.context),
            isNewListQuizPresented: $isNewListQuizPresented,
            currentStep: $currentStep,
            navigateToListView: $navigateToListView,
            currentPackingList: $currentPackingList,
            packingListCount: 3)
            .environment(WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder()))
    }
}
#endif
