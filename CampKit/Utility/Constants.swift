//
//  ConstantsExtension.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import Foundation
import SwiftUI

struct Constants {
    
    //PHOTOS
    static let photoK = ""
    static let photoSK = ""
    
    //UI STYLES
    static let titleFont: CGFloat = 36
    
    static let cornerRadius: CGFloat = 8
    static let cornerRadiusRounded: CGFloat = 18
    static let cornerRadiusButton: CGFloat = 13
    
    static let verticalSpacing: CGFloat = 10
    static let lineSpacing: CGFloat = 5
    static let cardSpacing: CGFloat = 20
    static let navSpacing: CGFloat = 20
    static let gridSpacing: CGFloat = 15
    static let headerSpacing: CGFloat = 70
    static let gallerySpacing: CGFloat = 4
    
    static let wideMargin: CGFloat = 30

    static let largePadding: CGFloat = 30
    static let horizontalPadding: CGFloat = 20
    static let bodyPadding: CGFloat = 70
    static let quizPadding: CGFloat = 150
    static let ipadPadding: CGFloat = 200
    static let defaultPadding: CGFloat = 16
    
    static let gradientBannerHeight: CGFloat = 120
    static let bannerHeight: CGFloat = 250
    static let ipadBannerHeight: CGFloat = 450
    
    static let homePageOffset: CGFloat = 1
    
    
    //STRINGS
    static let newPackingListTitle: String = "New Packing List"
    static let placeholderBannerPhoto: String = "PineShadow"
    
    //PRO
    static let proVersionListCount: Int = 3
    @AppStorage("successEmoji") var successEmoji: String = "🔥"
    static let productIDPro: String = "com.campingkitapp.pro"
    static let userDefaultsProKey: String = "ProPurchased"
}
