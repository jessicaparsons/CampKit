//
//  SwipeActionModifier.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftUI
import SwipeCell

struct SwipeActionModifier: ViewModifier {
    
    var viewModel: ListViewModel
    var item: Item
    var isFocused: Bool
    
    func body(content: Content) -> some View {
        if isFocused {
            content
        } else {
            content.swipeCell(
                cellPosition: .both,
                leftSlot: nil,
                rightSlot:
                    SwipeCellSlot(
                        slots: [
                            SwipeCellButton(buttonStyle: .view,
                                            title: "",
                                            systemImage: "",
                                            view: {
                                                AnyView(
                                                    Image(systemName: "trash")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 20, height: 20)
                                                        .foregroundColor(.white)
                                                )},
                                            backgroundColor: .red,
                                            action: {
                                                viewModel.deleteItem(item)
                                            },
                                            feedback:true
                                           ),
                            
                        ],
                        slotStyle: .destructiveDelay),
                swipeCellStyle: SwipeCellStyle(
                    alignment: .leading,
                    dismissWidth: 20,
                    appearWidth: 20,
                    destructiveWidth: 240,
                    vibrationForButton: .error,
                    vibrationForDestructive: .medium,
                    autoResetTime: 3)
            )
            .dismissSwipeCellForScrollViewForLazyVStack()
        }
    }
}
