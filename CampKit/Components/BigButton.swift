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
            .padding(.vertical, 13)
            .padding(.horizontal, Constants.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 50)
                    .fill(.colorNeon)
            )
            .foregroundColor(.black)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)

    }
}

struct BigButtonWide: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 15)
            .padding(.horizontal, Constants.horizontalPadding)
            //.frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.colorNeon)
            )
            .foregroundColor(.black)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)

    }
}

struct BigButtonLabel: View {
    
    let label: String
    
    var body: some View {
        HStack {
            Group {
                Image(systemName: "plus")
                    .fontWeight(.bold)
                Text(label)
                    .padding(3)
            }
            .font(.subheadline)
        }
    }
}


