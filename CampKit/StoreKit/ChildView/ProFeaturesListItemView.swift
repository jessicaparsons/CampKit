//
//  ProFeaturesListItemView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/21/25.
//

import SwiftUI

struct ProFeaturesListItemView: View {
    
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.colorForest)
                .font(.title)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(description)
                    .multilineTextAlignment(.leading)
                    .fontWeight(.light)
            }
            .padding(.leading, 8)
        }//:HSTACK
    }
}
#if DEBUG
#Preview {
    ProFeaturesListItemView(title: "Unlimited Packing Lists", description: "More descriptive text will go here about it")
}
#endif
