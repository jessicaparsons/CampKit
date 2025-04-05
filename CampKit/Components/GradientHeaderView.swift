//
//  GradientHeaderView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/5/25.
//

import SwiftUI

struct GradientHeaderView: View {
    
    let label: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [.customGold, .customSage, .customSky, .customLilac], startPoint: .bottomLeading, endPoint: .topTrailing)
                .ignoresSafeArea(edges: .top)
            VStack {
                Text(label)
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .padding(.bottom, 30)
            }//:VSTACK
        }//:ZSTACK
        .frame(height: 150)
    }
}

#Preview {
    GradientHeaderView(label: "Howdy, Camper!")
}
