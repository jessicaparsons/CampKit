//
//  ProgressBarView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/4/25.
//

import SwiftUI

struct ProgressBarView: View {
    
    @ObservedObject var viewModel: ListViewModel
    var packedRatio: Double
    var packedCount: Int
    var allItems: [Item]
    
    var body: some View {
        HStack {
            ProgressView(value: packedRatio)
                .progressViewStyle(LinearProgressViewStyle(tint: .colorSage))
                .animation(.easeInOut, value: packedRatio)
       
       
     
            Text("\(packedCount)/\(allItems.count)")
                .font(.subheadline)
                .fixedSize(horizontal: true, vertical: false)
            
        }//:HSTACK
        .padding(.horizontal, Constants.horizontalPadding)
        .frame(height: 20)
    }
}

#if DEBUG

#Preview {
    
    let previewStack = CoreDataStack.preview
    let viewModel = ListViewModel(viewContext: previewStack.context, packingList: PackingList.samplePackingList(context: previewStack.context))
    let allItems = viewModel.packingList.sortedCategories.flatMap { $0.sortedItems }
                                  
    ProgressBarView(
        viewModel: viewModel,
       packedRatio: viewModel.packedRatio,
       packedCount: viewModel.packedCount,
       allItems: allItems
    )
}
#endif
