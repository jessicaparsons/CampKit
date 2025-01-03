//
//  QuizData.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import Foundation

struct QuizData {
    var who: [String] = [] // Options: ["adult", "dog", "kids"]
    var location: String = "" // Optional location
    var elevation: Double = 0.0 // Slider value in feet
    var activities: [String] = [] // Options: ["hiking", "fishing", "bouldering", "water sports"]
    var weather: String = "" // Fetched dynamically
}
