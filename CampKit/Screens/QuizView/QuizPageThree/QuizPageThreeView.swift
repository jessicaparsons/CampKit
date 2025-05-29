//
//  QuizPageThreeView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/25/25.
//

import SwiftUI

struct QuizPageThreeView: View {
    
    @Bindable var viewModel: QuizViewModel
    
    var body: some View {
        BackgroundPickerView { image in
            viewModel.setTempPhoto(image)
        }
        .padding(.top, Constants.largePadding)
    }
}


#Preview {
    
    @Previewable @State var previewStack = CoreDataStack.preview
    @Previewable @State var isNewListQuizPresented: Bool = false
    @Previewable @State var navigateToListView: Bool = false
    @Previewable @State var currentPackingList: PackingList? = nil
    
    QuizPageThreeView(
        viewModel: QuizViewModel(context: previewStack.context)
    )
}
