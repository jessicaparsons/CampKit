//
//  HapticFeedbackUtility.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI

@MainActor
final class HapticsManager {
    static let shared = HapticsManager()

    private init() {} // Prevents external initialization

    private let mediumHaptics = UIImpactFeedbackGenerator(style: .medium)
    private let lightHaptics = UIImpactFeedbackGenerator(style: .light)
    private let heavyHaptics = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationHaptics = UINotificationFeedbackGenerator()

    func triggerMediumImpact() {
        //mediumHaptics.prepare()
        mediumHaptics.impactOccurred()
    }

    func triggerLightImpact() {
        //lightHaptics.prepare()
        lightHaptics.impactOccurred()
    }

    func triggerHeavyImpact() {
        //heavyHaptics.prepare()
        heavyHaptics.impactOccurred()
    }
    
    func triggerSuccess() {
        notificationHaptics.notificationOccurred(.success)
    }
}

