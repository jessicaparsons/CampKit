//
//  GradientBackground.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/29/25.
//

import SwiftUI

struct CampGradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [Color.colorSky, Color.colorLilac],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .overlay(
                    Color.black.opacity(0.5)
                        .blendMode(.overlay)
                )
            } else {
                LinearGradient(
                    colors: [Color.colorGold, Color.colorSage, Color.colorSky, Color.colorSky],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            }
        }
    }
}
