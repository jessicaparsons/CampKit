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
    
    
    //CORE DATA
    //let persistenceController = PersistenceController.shared
    private let persistentContainer = PersistenceController.shared.persistentContainer
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //WEATHER API
    var weatherViewModel = WeatherViewModel(weatherFetcher: WeatherAPIClient(), geoCoder: Geocoder())
    //STORE KIT
    let storeKitManager = StoreKitManager()

    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environment(weatherViewModel)
                .environment(storeKitManager)
                .task {
                    await requestNotificationPermission()
                }
        }
        
    }
    
    @MainActor
    func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            print("Notifications granted: \(granted)")
        } catch {
            print("Failed to get notification permission: \(error)")
        }
    }
}
