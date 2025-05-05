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
    let barWidth: CGFloat
    let numbersWidth: CGFloat
    
    var body: some View {
            GeometryReader { geo in
                HStack {
                    Spacer()
                    HStack {
                        ProgressView(value: packedRatio)
                            .progressViewStyle(LinearProgressViewStyle(tint: .colorNeon))
                            .animation(.easeInOut, value: packedRatio)
                    }//:HSTACK
                    .frame(width: geo.size.width * barWidth)
                    
                    HStack {
                        Text("\(packedCount)/\(allItems.count)")
                            .font(.subheadline)
                        Spacer()
                    }//:HSTACK
                    .frame(width: geo.size.width * numbersWidth)
                    Spacer()
                                        
                }//:HSTACK
            }//:GEOMETRY READER
            .padding(.horizontal, Constants.horizontalPadding)
            .frame(height: 20)
    }
}

#Preview {
    
    let previewStack = CoreDataStack.preview
    let viewModel = ListViewModel(viewContext: previewStack.context, packingList: PackingList.samplePackingList(context: previewStack.context))
    let allItems = viewModel.packingList.sortedCategories.flatMap { $0.sortedItems }
                                  
    ProgressBarView(
        viewModel: viewModel,
       packedRatio: viewModel.packedRatio,
       packedCount: viewModel.packedCount,
       allItems: allItems,
        barWidth: 0.75,
        numbersWidth: 0.25
    
    )
}
