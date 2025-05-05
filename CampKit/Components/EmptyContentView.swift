//
//  EmptyContentView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/4/25.
//

import SwiftUI

struct EmptyContentView: View {
    
    let icon: String
    let description: String
    
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: Constants.verticalSpacing) {
                Image(systemName: icon)
                    .foregroundStyle(Color.colorTertiaryGrey)
                    .font(.system(size: 100))
                
                Text(description)
                    .foregroundStyle(.secondary)
                
            }//:VSTACK
            .padding(.top, Constants.largePadding)
            Spacer()
        }//:HSTACK
    }
        
}

#Preview {
    ZStack {
        Color.colorWhiteSands
        EmptyContentView(
            icon: "tent.fill",
            description: "You haven't created any lists yet")
    }
}
