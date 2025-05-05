//
//  HeaderView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/3/25.
//

import SwiftUI

struct HeaderView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let title: String
    
    @Binding var scrollOffset: CGFloat
    let scrollThreshold: CGFloat
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, Constants.verticalSpacing)
                .padding(.horizontal, Constants.wideMargin)
                .offset(y: -10)
            Divider()
        }//:VSTACK
        .background(
            ZStack {
                if scrollOffset < -scrollThreshold {
                    Color.clear.background(.thinMaterial)
                } else {
                    Color.clear
                }
            }
            .ignoresSafeArea()
        )
    }
}

#Preview {
    @Previewable @State var scrollOffset: CGFloat = 1
    
    HeaderView(
        title: "Howdy, Camper",
        scrollOffset: $scrollOffset,
        scrollThreshold: 1
    )
}
