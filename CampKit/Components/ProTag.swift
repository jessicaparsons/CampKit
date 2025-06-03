//
//  ProTag.swift
//  CampKit
//
//  Created by Jessica Parsons on 6/3/25.
//

import SwiftUI

struct ProTag: View {
    var body: some View {
        Text("PRO")
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.colorBloodOrange)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .accessibilityLabel("Pro feature")
    }
}

#Preview {
    ProTag()
}
