//
//  PackingListTemplates.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/11/25.
//

import SwiftUI
import CoreData



//Dictionary with all category templates

let packingPreferenceCategories: [String: [String]] = [
    ChoiceOptions.participants: [ChoiceOptions.adults, ChoiceOptions.kids, ChoiceOptions.dogs],
    ChoiceOptions.activities: [ChoiceOptions.hiking, ChoiceOptions.fishing, ChoiceOptions.bouldering, ChoiceOptions.waterSports, ChoiceOptions.biking, ChoiceOptions.backpacking, ChoiceOptions.kayaking],
    ChoiceOptions.weatherConditions: [ChoiceOptions.mild, ChoiceOptions.hot, ChoiceOptions.cold, ChoiceOptions.snowy, ChoiceOptions.rainy]
    ]


func generateCategoryTemplates(using viewContext: NSManagedObjectContext) -> [String: [Item]] {
    return [
        "Clothing": [
            Item(context: viewContext, title: "Tshirts"),
            Item(context: viewContext, title: "Jacket"),
            Item(context: viewContext, title: "Hiking Boots"),
            Item(context: viewContext, title: "Rain Jacket")
        ],
        "Camping Gear": [
            Item(context: viewContext, title: "Tent"),
            Item(context: viewContext, title: "Sleeping Bag"),
            Item(context: viewContext, title: "Camp Stove")
        ],
        
        "First Aid": [
            Item(context: viewContext, title: "First Aid Kit"),
            Item(context: viewContext, title: "Bandaids"),
            Item(context: viewContext, title: "Poison Ivy Kit")
        ],
        
        //PARTICIPANTS
        
        ChoiceOptions.kids: [
            Item(context: viewContext, title: "Diapers"),
            Item(context: viewContext, title: "Toys"),
            Item(context: viewContext, title: "Extra Clothes")
        ],
        ChoiceOptions.dogs: [
            Item(context: viewContext, title: "Dog Food"),
            Item(context: viewContext, title: "Leash"),
            Item(context: viewContext, title: "Dog Bed")
        ],
        
        
        //ACTIVITIES
        ChoiceOptions.hiking: [
                Item(context: viewContext, title: "Hiking Boots"),
                Item(context: viewContext, title: "Trekking Poles"),
                Item(context: viewContext, title: "Trail Map")
        ],
        ChoiceOptions.fishing: [
            Item(context: viewContext, title: "Fishing Rod"),
            Item(context: viewContext, title: "Bait & Lures"),
            Item(context: viewContext, title: "Tackle Box")
        ],
        ChoiceOptions.bouldering: [
            Item(context: viewContext, title: "Climbing Shoes"),
            Item(context: viewContext, title: "Chalk Bag"),
            Item(context: viewContext, title: "Crash Pad")
        ],
        ChoiceOptions.waterSports: [
            Item(context: viewContext, title: "Swimsuit"),
            Item(context: viewContext, title: "Dry Bag"),
            Item(context: viewContext, title: "Snorkel Gear")
        ],
        ChoiceOptions.biking: [
            Item(context: viewContext, title: "Helmet"),
            Item(context: viewContext, title: "Bike Repair Kit"),
            Item(context: viewContext, title: "Gloves")
        ],
        ChoiceOptions.backpacking: [
            Item(context: viewContext, title: "Backpack"),
            Item(context: viewContext, title: "Water Filter"),
            Item(context: viewContext, title: "Sleeping Bag")
        ],
        ChoiceOptions.kayaking: [
            Item(context: viewContext, title: "Paddle"),
            Item(context: viewContext, title: "Life Jacket"),
            Item(context: viewContext, title: "Waterproof Bag")
        ],
        
        //WEATHER
        
        ChoiceOptions.hot: [
            Item(context: viewContext, title: "Sunscreen"),
            Item(context: viewContext, title: "Bathing Suit"),
            Item(context: viewContext, title: "Extra Water")
        ],
        
        ChoiceOptions.cold: [
            Item(context: viewContext, title: "Hand Warmers"),
            Item(context: viewContext, title: "Extra Blankets"),
            Item(context: viewContext, title: "Wool Socks")
        ],
        
        ChoiceOptions.snowy: [
            Item(context: viewContext, title: "Hand Warmers"),
            Item(context: viewContext, title: "Extra Blankets"),
            Item(context: viewContext, title: "Wool Socks")
        ],
        
        ChoiceOptions.rainy: [
            Item(context: viewContext, title: "Hand Warmers"),
            Item(context: viewContext, title: "Extra Blankets"),
            Item(context: viewContext, title: "Wool Socks")
        ]
        
    ]
}
