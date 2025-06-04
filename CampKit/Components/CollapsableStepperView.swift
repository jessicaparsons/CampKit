//
//  CollapsableStepper.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/6/25.
//

import SwiftUI

struct CollapsableStepperView: View {
    
    
    @Binding var value: Int
    let range: ClosedRange<Int>

    @State private var isExpanded: Bool = false
    @Binding var isPickerFocused: Bool
    
    var body: some View {
            ZStack {
                //MARK: - STEPPER
                if isExpanded {
                    HStack(spacing: 16) {
                        Button(action: {
                            if value > range.lowerBound {
                                value -= 1
                                HapticsManager.shared.triggerLightImpact()
                            }
                        }) {
                            Image(systemName: "minus")
                        }
                        .accessibilityHint("Lowers the value")

                        Text("\(value)")
                            

                        Button(action: {
                            if value < range.upperBound {
                                value += 1
                                HapticsManager.shared.triggerLightImpact()
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                        .accessibilityHint("Raises the value")
                    }
                    .font(.footnote)
                    .foregroundColor(.primary)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(Color.colorWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 999, style: .continuous)
                                    .stroke(Color.colorTertiaryGrey, lineWidth: 1)
                            )
                    )
                    .onTapGesture {
                        isPickerFocused = true
                    }
                    .onChange(of: isPickerFocused) {
                        if !isPickerFocused {
                            isExpanded = false
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
                    
                    //MARK: - QUANTITY BUTTON
                } else  {
                    Button(action: {
                        isExpanded = true
                        isPickerFocused.toggle()
                    }) {
                        Group {
                            if value > 0 {
                                Text("\(value)")
                                    
                            } else {
                                Image(systemName: "plus")
                                    
                                    
                            }
                        }
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .frame(width: 28, height: 25)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                                    .fill(Color.colorWhite)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                                            .stroke(Color.colorTertiaryGrey, lineWidth: 1)
                                    )
                            )
                    }
                    .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .opacity))
                    .accessibilityHint("Change the quantity")
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
        }
}


#if DEBUG

#Preview {
    
    @Previewable @State var value: Int = 3
    @Previewable @State var value2: Int = 0
    @Previewable @State var isPickerFocused = false
    
    HStack(spacing: 0) {
        CollapsableStepperView(value: $value2, range: 0...100, isPickerFocused: $isPickerFocused)
        CollapsableStepperView(value: $value, range: 0...100, isPickerFocused: $isPickerFocused)
        
    }
}

#endif
