//
//  String+Extension.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/10/25.
//

import Foundation

//Trims white spaces and new lines and checks if it's empty 

extension String {
    var isEmptyOrWhiteSpace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
