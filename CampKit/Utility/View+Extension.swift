//
//  ViewExtension.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/27/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func dynamicForegroundStyle(trigger: CGFloat, threshold: CGFloat = 1) -> some View {
        self.foregroundStyle(trigger < -threshold ? Color.primary : Color.white)
    }
}

    

