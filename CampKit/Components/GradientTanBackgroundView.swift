//
//  GradientTanBackgroundView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/8/25.
//

import SwiftUI

struct GradientTanBackgroundView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        
        ZStack(alignment: .top) {
            Group {
                if colorScheme == .dark {
                    
                    LinearGradient(
                        colors: [.customSky, .customLilac],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    Color.black
                        .opacity(0.5)
                        .blendMode(.overlay)
                    
                } else {
                    //LIGHT MODE
                    
                    LinearGradient(
                        colors: [.customGold, .customSage, .customSky, .customSky],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                }
            }
            .frame(height: 200) // This height should cover nav bar + status bar
            .ignoresSafeArea(edges: .top)
            
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .fill(Color.customTan)
                .ignoresSafeArea(.container, edges: [.bottom])
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: -2)
            
        }
    }//:ZSTACK
}

#Preview {
    NavigationStack {
        GradientTanBackgroundView()
    }
}
