//
//  PresetImage.swift
//  CampKit
//
//  Created by Jessica Parsons on 6/3/25.
//

import Foundation

struct PresetImage: Identifiable, Equatable {
    let id = UUID()
    let name: String
}

let presetImages: [PresetImage] = [
    PresetImage(name: "CanyonHeat"),
    PresetImage(name: "DarkGrove"),
    PresetImage(name: "DeepwaterKelp"),
    PresetImage(name: "DesertBloom"),
    PresetImage(name: "DustDrift"),
    PresetImage(name: "Emberwood"),
    PresetImage(name: "GlacierBay"),
    PresetImage(name: "GoldenHour"),
    PresetImage(name: "MorningMist"),
    PresetImage(name: "PineShadow"),
    PresetImage(name: "RedRockBlush"),
    PresetImage(name: "StormRidge")
]
