//
//  ViewExtensions.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/23/25.
//

import Foundation
import SwiftUI

// MARK: - Keyboard Dismissal Function
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
