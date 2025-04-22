//
//  Character+Extension.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/21/25.
//

import Foundation


extension Character {
    var isEmoji: Bool {
        unicodeScalars.contains { $0.properties.isEmoji && ($0.value > 0x238C || $0.properties.isEmojiPresentation) }
    }
}
