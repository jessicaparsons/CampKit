//
//  QuizChoicesModels.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/13/25.
//

import SwiftData

@Model
class Participant {
    var name: String
    var packingList: PackingList?
    
    init(name: String) {
        self.name = name
    }
}


@Model
class Activity {
    var name: String
    var packingList: PackingList?
    
    init(name: String) {
        self.name = name
    }
}

@Model
class WeatherCondition {
    var name: String
    var packingList: PackingList?
    
    init(name: String) {
        self.name = name
    }
}
