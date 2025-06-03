//
//  ColoredToggleStyle.swift
//  CampKit
//
//  Created by Jessica Parsons on 6/3/25.
//

import SwiftUI

struct ColoredToggleStyle: ToggleStyle {
    var label: String
    var onColor: Color
    var offColor: Color
    var thumbColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Text(label)
            Spacer()
            Button(action: { configuration.isOn.toggle() } )
            {
                RoundedRectangle(cornerRadius: 16, style: .circular)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 50, height: 29)
                    .overlay(
                        Circle()
                            .fill(thumbColor)
                            .shadow(radius: 1, x: 0, y: 1)
                            .padding(1.5)
                            .offset(x: configuration.isOn ? 10 : -10))
            }//:BUTTON
            .animation(Animation.easeInOut(duration: 0.1), value: configuration.isOn)
        }
    }
}
