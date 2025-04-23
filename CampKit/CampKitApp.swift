//
//  CampKitApp.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI
import UserNotifications

@main
struct CampKitApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    //CORE DATA
    //WEATHER API
    var weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    //STORE KIT
    let storeKitManager = StoreKitManager()

    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
                .environment(weatherViewModel)
                .environment(storeKitManager)
        }
        
    }
    
}
