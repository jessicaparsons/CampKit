//
//  GradientOption.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/27/25.
//

import SwiftUI

struct GradientOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let gradient: LinearGradient

    static func == (lhs: GradientOption, rhs: GradientOption) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

let presetGradients: [GradientOption] = [
    GradientOption(
        name: "Sunset Peak",
        gradient: LinearGradient(
            colors: [Color("#E84D10"), Color("#DFFF59")],
            startPoint: .top,
            endPoint: .bottom)
    ),
    GradientOption(
        name: "Deep Forest",
        gradient: LinearGradient(
            colors: [Color("#11270C"), Color("#81997C")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    ),
    GradientOption(
        name: "Morning Fog",
        gradient: LinearGradient(
            colors: [Color("#F1F1F0"), Color("#81997C")],
            startPoint: .top,
            endPoint: .bottom)
    ),
    GradientOption(
        name: "Spring Meadow",
        gradient: LinearGradient(
            colors: [Color("#DFFF59"), Color("#F1F1F0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    ),
    GradientOption(
        name: "Mountain Lake",
        gradient: LinearGradient(
            colors: [Color("#A8DADC"), Color("#457B9D")],
            startPoint: .top,
            endPoint: .bottom)
    ),
    GradientOption(
        name: "Wildflower Bloom",
        gradient: LinearGradient(
            colors: [Color("#DFFF59"), Color("#B497BD")],
            startPoint: .top,
            endPoint: .bottom)
    ),
    GradientOption(
        name: "Twilight Sky",
        gradient: LinearGradient(
            colors: [Color("#6D597A"), Color("#355070")],
            startPoint: .top,
            endPoint: .bottom)
    ),
    GradientOption(
        name: "Ocean Mist",
        gradient: LinearGradient(
            colors: [Color("#CAE9FF"), Color("#A2D2FF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    ),
    GradientOption(
        name: "Canyon Dust",
        gradient: LinearGradient(
            colors: [Color("#E84D10"), Color("#11270C")],
            startPoint: .top,
            endPoint: .bottom)
    )
]

