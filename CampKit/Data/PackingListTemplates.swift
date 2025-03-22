//
//  PackingListTemplates.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/11/25.
//

import Foundation


//Dictionary with all category templates

let packingPreferenceCategories: [String: [String]] = [
    ChoiceOptions.participants: [ChoiceOptions.adults, ChoiceOptions.kids, ChoiceOptions.dogs],
    ChoiceOptions.activities: [ChoiceOptions.hiking, ChoiceOptions.fishing, ChoiceOptions.bouldering, ChoiceOptions.waterSports, ChoiceOptions.biking, ChoiceOptions.backpacking, ChoiceOptions.kayaking],
    ChoiceOptions.weatherConditions: [ChoiceOptions.mild, ChoiceOptions.hot, ChoiceOptions.cold, ChoiceOptions.snowy, ChoiceOptions.rainy]
    ]


@MainActor
let categoryTemplates: [String: [Item]] = [
    
    
    //DEFAULTS
    
    "Clothing": [
        Item(title: "Tshirts"),
        Item(title: "Jacket"),
        Item(title: "Hiking Boots"),
        Item(title: "Rain Jacket")
    ],
    "Camping Gear": [
        Item(title: "Tent"),
        Item(title: "Sleeping Bag"),
        Item(title: "Camp Stove")
    ],
    
    "First Aid": [
        Item(title: "First Aid Kit"),
        Item(title: "Bandaids"),
        Item(title: "Poison Ivy Kit")
    ],
    
    //PARTICIPANTS
    
    ChoiceOptions.kids: [
        Item(title: "Diapers"),
        Item(title: "Toys"),
        Item(title: "Extra Clothes")
    ],
    ChoiceOptions.dogs: [
        Item(title: "Dog Food"),
        Item(title: "Leash"),
        Item(title: "Dog Bed")
    ],
    
    
    //ACTIVITIES
    ChoiceOptions.hiking: [
            Item(title: "Hiking Boots"),
            Item(title: "Trekking Poles"),
            Item(title: "Trail Map")
    ],
    ChoiceOptions.fishing: [
        Item(title: "Fishing Rod"),
        Item(title: "Bait & Lures"),
        Item(title: "Tackle Box")
    ],
    ChoiceOptions.bouldering: [
        Item(title: "Climbing Shoes"),
        Item(title: "Chalk Bag"),
        Item(title: "Crash Pad")
    ],
    ChoiceOptions.waterSports: [
        Item(title: "Swimsuit"),
        Item(title: "Dry Bag"),
        Item(title: "Snorkel Gear")
    ],
    ChoiceOptions.biking: [
        Item(title: "Helmet"),
        Item(title: "Bike Repair Kit"),
        Item(title: "Gloves")
    ],
    ChoiceOptions.backpacking: [
        Item(title: "Backpack"),
        Item(title: "Water Filter"),
        Item(title: "Sleeping Bag")
    ],
    ChoiceOptions.kayaking: [
        Item(title: "Paddle"),
        Item(title: "Life Jacket"),
        Item(title: "Waterproof Bag")
    ],
    
    //WEATHER
    
    ChoiceOptions.hot: [
        Item(title: "Sunscreen"),
        Item(title: "Bathing Suit"),
        Item(title: "Extra Water")
    ],
    
    ChoiceOptions.cold: [
        Item(title: "Hand Warmers"),
        Item(title: "Extra Blankets"),
        Item(title: "Wool Socks")
    ],
    
    ChoiceOptions.snowy: [
        Item(title: "Hand Warmers"),
        Item(title: "Extra Blankets"),
        Item(title: "Wool Socks")
    ],
    
    ChoiceOptions.rainy: [
        Item(title: "Hand Warmers"),
        Item(title: "Extra Blankets"),
        Item(title: "Wool Socks")
    ]
    
]
