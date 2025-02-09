//
//  ChipSectionView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI
import SwiftData

struct ChipSectionView: View {
    
    @Binding var choices: [Choice]
    
    
    var body: some View {
        
        FlowLayout {
            ForEach(choices) { choice in
                ChipButtonsView(label: choice.name, isSelected: choice.isSelected)
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
            }
        }//:FLOWLAYOUT
    }
}

struct FlowLayout: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width
                lineHeight = max(lineHeight, size.height)
            }

            totalWidth = max(totalWidth, lineWidth)
        }

        totalHeight += lineHeight

        return .init(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0

        for index in subviews.indices {
            if lineX + sizes[index].width > (proposal.width ?? 0) {
                lineY += lineHeight
                lineHeight = 0
                lineX = bounds.minX
            }

            subviews[index].place(
                at: .init(
                    x: lineX + sizes[index].width / 2,
                    y: lineY + sizes[index].height / 2
                ),
                anchor: .center,
                proposal: ProposedViewSize(sizes[index])
            )

            lineHeight = max(lineHeight, sizes[index].height)
            lineX += sizes[index].width
        }
    }
}

#Preview {
    
    @Previewable @State var sampleChoices: [Choice] = [
        Choice(name: "Adults", isSelected: false),
        Choice(name: "Kids", isSelected: false),
        Choice(name: "Dogs", isSelected: false)
    ]
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    //let viewModel = QuizViewModel(modelContext: container.mainContext)
    
    ChipSectionView(choices: $sampleChoices)
}
