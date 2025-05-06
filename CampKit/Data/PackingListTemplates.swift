//
//  PackingListTemplates.swift
//  CampKit
//
//  Created by Jessica Parsons on 3/11/25.
//

import SwiftUI
import CoreData



//Dictionary with all category templates

 func setCategoryOrder() -> [String: Int64] {
     
     let orderedCategories: [String] = [
        ChoiceOptions.sleep,
        ChoiceOptions.kitchen,
        ChoiceOptions.foodStaples,
        ChoiceOptions.tools,
        ChoiceOptions.clothing,
        ChoiceOptions.toiletries,
        ChoiceOptions.emergency,
        ChoiceOptions.lounge,
        ChoiceOptions.adults,
        ChoiceOptions.kids,
        ChoiceOptions.pets,
        ChoiceOptions.hiking,
        ChoiceOptions.waterSports,
        ChoiceOptions.bouldering,
        ChoiceOptions.biking,
        ChoiceOptions.backpacking,
        ChoiceOptions.fishing,
        ChoiceOptions.hunting,
        ChoiceOptions.hot,
        ChoiceOptions.cold,
        ChoiceOptions.snowy,
        ChoiceOptions.rainy
     ]
     
     var categoryOrder: [String: Int64] = [:]
     
     for (index, category) in orderedCategories.reversed().enumerated() {
         categoryOrder[category] = Int64(index)
     }
     
     return categoryOrder
}



let packingPreferenceCategories: [String: [String]] = [
    ChoiceOptions.defaults: [ChoiceOptions.sleep, ChoiceOptions.kitchen, ChoiceOptions.foodStaples, ChoiceOptions.tools, ChoiceOptions.clothing, ChoiceOptions.toiletries, ChoiceOptions.emergency, ChoiceOptions.lounge],
    
    
    ChoiceOptions.participants: [ChoiceOptions.adults, ChoiceOptions.kids, ChoiceOptions.pets],
    ChoiceOptions.addParticipants: [ChoiceOptions.kids, ChoiceOptions.pets],

    
    ChoiceOptions.activities: [ChoiceOptions.hiking, ChoiceOptions.waterSports, ChoiceOptions.bouldering, ChoiceOptions.biking, ChoiceOptions.backpacking, ChoiceOptions.fishing, ChoiceOptions.hunting],
    
    
    ChoiceOptions.weatherConditions: [ChoiceOptions.mild, ChoiceOptions.hot, ChoiceOptions.cold, ChoiceOptions.snowy, ChoiceOptions.rainy],
    ChoiceOptions.addWeatherConditions: [ChoiceOptions.hot, ChoiceOptions.cold, ChoiceOptions.snowy, ChoiceOptions.rainy]
    
    
    ]


func generateCategoryTemplates(using viewContext: NSManagedObjectContext) -> [String: [Item]] {
    return [
        
        //GENERAL CATEGORIES
        ChoiceOptions.sleep: [
            Item(context: viewContext, title: "Tent"),
            Item(context: viewContext, title: "Footprint/tarp"),
            Item(context: viewContext, title: "Sleeping bag (temp rated)"),
            Item(context: viewContext, title: "Sleeping pad"),
            Item(context: viewContext, title: "Pillows"),
            Item(context: viewContext, title: "Extra blankets")
        ],
        ChoiceOptions.kitchen: [
            Item(context: viewContext, title: "Propane/fuel"),
            Item(context: viewContext, title: "Pots and pans"),
            Item(context: viewContext, title: "Plates and bowls"),
            Item(context: viewContext, title: "Coffee mugs"),
            Item(context: viewContext, title: "Cooking knives"),
            Item(context: viewContext, title: "Utensils"),
            Item(context: viewContext, title: "Paper towels"),
            Item(context: viewContext, title: "Coffee brewer"),
            Item(context: viewContext, title: "Cooler"),
            Item(context: viewContext, title: "Dry bag"),
            Item(context: viewContext, title: "Water (2 gal/pp/day)"),
            Item(context: viewContext, title: "Water bottles"),
            Item(context: viewContext, title: "Thermos"),
            Item(context: viewContext, title: "Dish soap & sponge/brush"),
            Item(context: viewContext, title: "Trash bags"),
            Item(context: viewContext, title: "Food storage containers"),
            Item(context: viewContext, title: "Cutting board"),
            Item(context: viewContext, title: "Can/bottle opener"),
            Item(context: viewContext, title: "Scissors")
        ],
        ChoiceOptions.foodStaples: [
            Item(context: viewContext, title: "Ice"),
            Item(context: viewContext, title: "Coffee/creamer/sweetener"),
            Item(context: viewContext, title: "Tea"),
            Item(context: viewContext, title: "Condiments"),
            Item(context: viewContext, title: "Cooking spices"),
            Item(context: viewContext, title: "Oil/butter"),
            Item(context: viewContext, title: "Snacks and energy bars")
        ],
        ChoiceOptions.tools: [
            Item(context: viewContext, title: "Firewood"),
            Item(context: viewContext, title: "Headlamps"),
            Item(context: viewContext, title: "Camp lights and lanterns"),
            Item(context: viewContext, title: "Extra batteries"),
            Item(context: viewContext, title: "Power station/bank"),
            Item(context: viewContext, title: "Extra stakes"),
            Item(context: viewContext, title: "Paracord/rope"),
            Item(context: viewContext, title: "Utility knife/multi-tool"),
            Item(context: viewContext, title: "Fire starter"),
            Item(context: viewContext, title: "Matches/lighter/flint"),
            Item(context: viewContext, title: "Bug spray"),
            Item(context: viewContext, title: "Hand sanitizer"),
            Item(context: viewContext, title: "Toilet paper/wet wipes"),
            Item(context: viewContext, title: "Duct tape"),
            Item(context: viewContext, title: "Mallet"),
            Item(context: viewContext, title: "Camp shower"),
            Item(context: viewContext, title: "Trowel")
        ],
        ChoiceOptions.clothing: [
            Item(context: viewContext, title: "Moisture-wicking shirts"),
            Item(context: viewContext, title: "Quick-dry pants/shorts"),
            Item(context: viewContext, title: "Jackets"),
            Item(context: viewContext, title: "Hats"),
            Item(context: viewContext, title: "Socks: hiking/warm"),
            Item(context: viewContext, title: "Undergarments"),
            Item(context: viewContext, title: "Comfortable shoes"),
            Item(context: viewContext, title: "Boots"),
            Item(context: viewContext, title: "Towels"),
            Item(context: viewContext, title: "Pajamas/sweats"),
            Item(context: viewContext, title: "Sunglasses"),
            Item(context: viewContext, title: "Watch/jewelry")
        ],
        ChoiceOptions.toiletries: [
            Item(context: viewContext, title: "Medications/supplements"),
            Item(context: viewContext, title: "Toothpaste/toothbrush"),
            Item(context: viewContext, title: "Brush/comb"),
            Item(context: viewContext, title: "Deodorant"),
            Item(context: viewContext, title: "Face cleanser/moisturizer"),
            Item(context: viewContext, title: "Sunscreen"),
            Item(context: viewContext, title: "Chapstick"),
            Item(context: viewContext, title: "Feminine products"),
            Item(context: viewContext, title: "Makeup/skincare"),
            Item(context: viewContext, title: "Small mirror")
        ],
        ChoiceOptions.emergency: [
            Item(context: viewContext, title: "First aid kit"),
            Item(context: viewContext, title: "Whistle"),
            Item(context: viewContext, title: "Navigation tools"),
            Item(context: viewContext, title: "Bear spray (if in bear country)"),
            Item(context: viewContext, title: "Cash")
        ],
        ChoiceOptions.lounge: [
            Item(context: viewContext, title: "Camp chairs"),
            Item(context: viewContext, title: "Shade pop-up/canopy"),
            Item(context: viewContext, title: "Electronics/BT speakers"),
            Item(context: viewContext, title: "Books"),
            Item(context: viewContext, title: "Cards/games"),
            Item(context: viewContext, title: "Instruments"),
            Item(context: viewContext, title: "Camera")
        ],
        
        
        //PARTICIPANTS
        
        ChoiceOptions.kids: [
            Item(context: viewContext, title: "Extra underwear/socks"),
            Item(context: viewContext, title: "Hats: warm/sun"),
            Item(context: viewContext, title: "Kid-friendly sunscreen"),
            Item(context: viewContext, title: "Kid-friendly bug spray"),
            Item(context: viewContext, title: "Medications"),
            Item(context: viewContext, title: "Wet wipes & tissues"),
            Item(context: viewContext, title: "Diapers/pull-ups"),
            Item(context: viewContext, title: "Baby care products"),
            Item(context: viewContext, title: "Stuffed animal or favorite toy"),
            Item(context: viewContext, title: "Kid-friendly snacks"),
            Item(context: viewContext, title: "Sippy cup or child-safe mug"),
            Item(context: viewContext, title: "Bib/mess mat"),
            Item(context: viewContext, title: "Art supplies/games"),
            Item(context: viewContext, title: "Books"),
            Item(context: viewContext, title: "Laundry bag"),
            Item(context: viewContext, title: "Travel fan")
        ],
        
        ChoiceOptions.pets: [
            Item(context: viewContext, title: "Pet food"),
            Item(context: viewContext, title: "Food and water bowls"),
            Item(context: viewContext, title: "Stake/tie-out"),
            Item(context: viewContext, title: "Leash"),
            Item(context: viewContext, title: "Pet bed"),
            Item(context: viewContext, title: "Waste bags"),
            Item(context: viewContext, title: "Pet toys"),
            Item(context: viewContext, title: "Pet jacket/clothing")
        ],
        
        
        //ACTIVITIES
        ChoiceOptions.hiking: [
            Item(context: viewContext, title: "Day pack/backpack"),
            Item(context: viewContext, title: "Hiking boots"),
            Item(context: viewContext, title: "Trekking poles"),
            Item(context: viewContext, title: "Trail map"),
            Item(context: viewContext, title: "Trail snacks"),
            Item(context: viewContext, title: "Extra water/water filter")
        ],
        
        ChoiceOptions.waterSports: [
            Item(context: viewContext, title: "Bathing suit"),
            Item(context: viewContext, title: "Beach towels"),
            Item(context: viewContext, title: "Sandals/water shoes"),
            Item(context: viewContext, title: "Inner tubes/floats"),
            Item(context: viewContext, title: "Kayaks/paddles/surfboard"),
            Item(context: viewContext, title: "Wetsuit/rash guard"),
            Item(context: viewContext, title: "Life vests"),
            Item(context: viewContext, title: "Dry bags"),
            Item(context: viewContext, title: "Waterproof case"),
            Item(context: viewContext, title: "Bilge pump")
        ],
        
        ChoiceOptions.bouldering: [
            Item(context: viewContext, title: "Climbing shoes"),
            Item(context: viewContext, title: "Climbing pants"),
            Item(context: viewContext, title: "Chalk bag and chalk"),
            Item(context: viewContext, title: "Crash pad(s)"),
            Item(context: viewContext, title: "Tape for fingers"),
            Item(context: viewContext, title: "Bouldering brush"),
            Item(context: viewContext, title: "Skin salve/balm"),
            Item(context: viewContext, title: "Guidebook/route info")
        ],
        
        ChoiceOptions.biking: [
            Item(context: viewContext, title: "Bike"),
            Item(context: viewContext, title: "Spare inner tube"),
            Item(context: viewContext, title: "Tire levers"),
            Item(context: viewContext, title: "Bike pump"),
            Item(context: viewContext, title: "Bike lights"),
            Item(context: viewContext, title: "Bike lock"),
            Item(context: viewContext, title: "Bike bags/panniers"),
            Item(context: viewContext, title: "Electrolytes"),
            Item(context: viewContext, title: "Energy bars/gels"),
            Item(context: viewContext, title: "Padded cycling shorts"),
            Item(context: viewContext, title: "Cycling gloves"),
            Item(context: viewContext, title: "Helmet"),
            Item(context: viewContext, title: "Cycling shoes")
        ],
        ChoiceOptions.backpacking: [
            Item(context: viewContext, title: "Multi-day backpack"),
            Item(context: viewContext, title: "Pack rain cover"),
            Item(context: viewContext, title: "Stuff sacks"),
            Item(context: viewContext, title: "Lightweight stove/fuel"),
            Item(context: viewContext, title: "Cookpot"),
            Item(context: viewContext, title: "Utensils (spork, etc.)"),
            Item(context: viewContext, title: "Lightweight bowl/cup"),
            Item(context: viewContext, title: "Lightweight sleeping pad"),
            Item(context: viewContext, title: "Lightweight tent"),
            Item(context: viewContext, title: "Water filter/purification"),
            Item(context: viewContext, title: "Backpacking meals"),
            Item(context: viewContext, title: "bear-proof food storage"),
            Item(context: viewContext, title: "Permits")
        ],
        
        ChoiceOptions.fishing: [
            Item(context: viewContext, title: "Fishing vest"),
            Item(context: viewContext, title: "Polarized sunglasses"),
            Item(context: viewContext, title: "Waterproof boots/waders"),
            Item(context: viewContext, title: "Fishing rod/reel"),
            Item(context: viewContext, title: "Fishing license"),
            Item(context: viewContext, title: "Tackle box"),
            Item(context: viewContext, title: "Line cutter/scissors"),
            Item(context: viewContext, title: "Pliers/forceps"),
            Item(context: viewContext, title: "Extra fishing line"),
            Item(context: viewContext, title: "Bait/fly selection"),
            Item(context: viewContext, title: "Landing net"),
            Item(context: viewContext, title: "Stringer/fish basket"),
            Item(context: viewContext, title: "Fillet knife"),
            Item(context: viewContext, title: "Measuring tape")
        ],
        
        ChoiceOptions.hunting: [
            Item(context: viewContext, title: "Camo gear"),
            Item(context: viewContext, title: "Orange safety vest/hat"),
            Item(context: viewContext, title: "Hunting license/tags"),
            Item(context: viewContext, title: "Weapons with case"),
            Item(context: viewContext, title: "Ammunition/arrows"),
            Item(context: viewContext, title: "Cleaning kit"),
            Item(context: viewContext, title: "Range finder"),
            Item(context: viewContext, title: "Game bags"),
            Item(context: viewContext, title: "Scent elimination products"),
            Item(context: viewContext, title: "Calls/decoys"),
            Item(context: viewContext, title: "Safety harness"),
            Item(context: viewContext, title: "Rope"),
            Item(context: viewContext, title: "Two-way radios"),
            Item(context: viewContext, title: "Flagging tape"),
            Item(context: viewContext, title: "Gut hook"),
            Item(context: viewContext, title: "Bone saw"),
            Item(context: viewContext, title: "Latex/nitrile gloves"),
            Item(context: viewContext, title: "Seat pad")
        ],
        
        //WEATHER
        
        ChoiceOptions.hot: [
            Item(context: viewContext, title: "2-3x Extra water"),
            Item(context: viewContext, title: "Extra sunscreen"),
            Item(context: viewContext, title: "Lip balm with SPF"),
            Item(context: viewContext, title: "Sun hat"),
            Item(context: viewContext, title: "Extra Sunshade or canopy"),
            Item(context: viewContext, title: "Portable fan")
        ],
        
        ChoiceOptions.cold: [
            Item(context: viewContext, title: "Thermal/wool layers"),
            Item(context: viewContext, title: "Gloves/mittens"),
            Item(context: viewContext, title: "Warm hat"),
            Item(context: viewContext, title: "Hand warmers"),
            Item(context: viewContext, title: "Wool socks"),
            Item(context: viewContext, title: "Extra blankets"),
            Item(context: viewContext, title: "Hot water bottle"),
            Item(context: viewContext, title: "Insulated mug")
        ],
        
        ChoiceOptions.snowy: [
            Item(context: viewContext, title: "Four-season tent"),
            Item(context: viewContext, title: "Insulated groundsheet"),
            Item(context: viewContext, title: "Snow stakes/anchors"),
            Item(context: viewContext, title: "Shovel"),
            Item(context: viewContext, title: "Gaiters"),
            Item(context: viewContext, title: "Waterproof boots"),
            Item(context: viewContext, title: "Snowshoes/backcountry skis"),
            Item(context: viewContext, title: "Avalanche beacon"),
            Item(context: viewContext, title: "Snow goggles"),
            Item(context: viewContext, title: "Ice axe"),
            Item(context: viewContext, title: "Crampons")
        ],
        
        ChoiceOptions.rainy: [
            Item(context: viewContext, title: "Waterproof shoes"),
            Item(context: viewContext, title: "Rain coat/poncho"),
            Item(context: viewContext, title: "Extra stakes"),
            Item(context: viewContext, title: "Guy lines"),
            Item(context: viewContext, title: "Extra towels"),
            Item(context: viewContext, title: "Tarps")
        ]
        
    ]
}
