//
//  StepperView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/6/25.
//

import SwiftUI

struct StepperView: View {
    
    
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                        HapticsManager.shared.triggerLightImpact()
                    }
                }) {
                    Image(systemName: "minus")
                }
                
                Text("\(value)")
                
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                        HapticsManager.shared.triggerLightImpact()
                    }
                }) {
                    Image(systemName: "plus")
                        
                }
            }//:GROUP
            .foregroundColor(.primary)
            .font(.caption)
            .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20).background(Capsule().fill(Color.clear).overlay(Capsule().stroke(Color.colorToggleOff, lineWidth: 1)))
        .animation(.easeInOut, value: value)
        
    }
}

#Preview {
    
    @Previewable @State var value: Int = 1
    
    StepperView(value: $value, range: 0...100)
}
