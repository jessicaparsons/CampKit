//
//  ChipButtonsView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI

struct ChipButtonsView: View {
    
    let label: String
    var isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
    
        Text(label)
            .font(.caption)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .fill(Color.clear)
                    .stroke(isSelected ? Color.colorSage : Color.colorToggleOff, lineWidth: 1)
            )
            .onTapGesture {
                onTap()
                HapticsManager.shared.triggerLightImpact()
            }
    }
}

#if DEBUG
#Preview {
    
    @Previewable @State var isSelected: Bool = true
    
    ChipButtonsView(label: "label", isSelected: isSelected, onTap: {  })
}
#endif
