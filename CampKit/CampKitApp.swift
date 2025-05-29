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
    //WEATHER API
    var weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    //STORE KIT
    let storeKitManager = StoreKitManager()
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor(named:"ColorSecondaryMenu")
        
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                if try await center.requestAuthorization(options: [.alert, .sound, .badge]) == true {
                    print("success")
                } else {
                    print("fail")
                }
                
            } catch {
                print("Error")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
                .environment(weatherViewModel)
                .environment(storeKitManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        
    }
    
}
