//
//  ConstantsExtension.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import Foundation
import SwiftUI

struct Constants {
    
    //API
    static let apiKey = "REDACTED"
    static let weatherURL = "https://api.openweathermap.org/data/2.5/forecast"
    
    //UI STYLES
    static let titleFont: CGFloat = 36
    static let cornerRadius: CGFloat = 8
    static let cornerRadiusRounded: CGFloat = 18
    static let verticalSpacing: CGFloat = 10
    static let lineSpacing: CGFloat = 5
    static let cardSpacing: CGFloat = 20
    static let largePadding: CGFloat = 30
    static let horizontalPadding: CGFloat = 20
    static let wideMargin: CGFloat = 30
    static let bodyPadding: CGFloat = 70
    static let gradientBannerHeight: CGFloat = 120
    static let navSpacing: CGFloat = 20
    static let quizPadding: CGFloat = 150
    static let gridSpacing: CGFloat = 15
    static let headerSpacing: CGFloat = 70
    
    //STRINGS
    static let newPackingListTitle: String = "New Packing List"
    
    //PRO
    static let proVersionListCount: Int = 3
    @AppStorage("successEmoji") var successEmoji: String = "🔥"
}
