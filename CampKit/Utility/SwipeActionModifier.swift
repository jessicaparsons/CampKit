//
//  SwipeActionModifier.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftUI
import SwipeCell

struct SwipeActionModifier: ViewModifier {
    
    var isFocused: Bool
    var isList: Bool
    let deleteAction: () -> Void
    
    func body(content: Content) -> some View {
        if !isFocused && !isList {
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
                                                deleteAction()
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
        } else {
            content
        }
    }
}
