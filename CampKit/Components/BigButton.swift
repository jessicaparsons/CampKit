//
//  CustomButton.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/3/25.
//

import SwiftUI

struct BigButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .controlSize(.large)
            .buttonBorderShape(.capsule)
            .tint(.colorNeon)
            .foregroundColor(.black)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

#Preview {
    //CustomButton()
}
