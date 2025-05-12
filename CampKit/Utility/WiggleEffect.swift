//
//  WiggleEffect.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/9/25.
//

import SwiftUI

struct WiggleEffect: ViewModifier {
    @State private var rotation: Double = -1
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isActive ? rotation : 0))
            .onAppear {
                if isActive {
                    startWiggling()
                }
            }
            .onChange(of: isActive) {
               
                    // Restart animation from beginning
                    rotation = -1
                    startWiggling()
                
            }
    }

    private func startWiggling() {
        withAnimation(Animation.linear(duration: 0.15).repeatForever(autoreverses: true)) {
            rotation = 1
        }
    }
}
