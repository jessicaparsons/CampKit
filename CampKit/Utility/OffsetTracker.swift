//
//  OffsetTracker.swift
//  CampKit
//
//  Created by Jessica Parsons on 6/3/25.
//

import SwiftUI

struct OffsetTracker: ViewModifier {
    @Binding var offset: CGFloat
    @State private var initialY: CGFloat?

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            if initialY == nil {
                                initialY = geo.frame(in: .global).minY
                            }
                        }
                        .onChange(of: geo.frame(in: .global).minY) {
                            if let start = initialY {
                                offset -= start
                            }
                        }
                }
            )
    }
}
