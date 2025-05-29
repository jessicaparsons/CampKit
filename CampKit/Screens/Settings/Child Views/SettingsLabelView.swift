//
//  SettingsLabelView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/15/25.
//

import SwiftUI

struct SettingsLabelView: View {
    
    var labelText: String
    var labelImage: String
    
    var body: some View {
        HStack {
            Text(labelText.uppercased()).fontWeight(.medium)
            Spacer()
            Image(systemName: labelImage)
        }
        
        
    }
}
#if DEBUG
#Preview {
    SettingsLabelView(labelText: "CampKit", labelImage: "info.circle")
}

#endif
