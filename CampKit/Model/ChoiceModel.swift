//
//  ChoiceModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import Foundation
import SwiftUI

struct Choice: Identifiable {
    let id = UUID()
    let name: String
    @State var isSelected: Bool
}
