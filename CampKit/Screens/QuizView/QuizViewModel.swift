//
//  QuizViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI
import CoreLocation
import CoreData

@Observable
final class QuizViewModel {
    
    //MARK: - PROPERTIES
    
    private let viewContext: NSManagedObjectContext
    
    var selectedFilters: Set<String> = []
    
    var listTitle: String = ""
    var locationName: String?
    var locationAddress: String?
    var latitude: Double?
    var longitude: Double?
    var elevation: Double = 0
    
    //Stores the packing list so the user gets sent to it after creation
    var currentPackingList: PackingList?
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    //MARK: - METHODS
    
    @MainActor
    func createPackingList() {
        withAnimation {
            
            // filters the choices to include only the selected items
            // where 'isSelected' is true, then maps the filtered result to an array of their names
            // inserts the choices into the context
            
            let lists = fetchPackingLists()
            
            for list in lists {
                list.position += 1
            }
            
            let newPackingList = PackingList(
                context: viewContext,
                title: listTitle.isEmpty ? "My Packing List" : listTitle, position: 0,
                locationName: (locationName == nil) ? nil : locationName,
                locationAddress: (locationAddress == nil) ? nil : locationAddress,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation
            )
            
            //Generate recommended categories and items
            let categories = generateCategories(from: newPackingList, using: viewContext)
            categories.forEach { newPackingList.addToCategories($0)
            }
            
            //Expand the first category in the UI
            newPackingList.sortedCategories.last?.isExpanded = true
            
            save(viewContext)
            
            currentPackingList = newPackingList
        }
        
    }
    
    func createBlankPackingList() {
        
        let lists = try? viewContext.fetch(PackingList.fetchRequest())
        lists?.forEach{ $0.position += 1 }
        
        withAnimation {
            let newPackingList = PackingList(
                context: viewContext,
                title: "My Packing List", position: 0,
                locationName: nil,
                locationAddress: nil,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation
            )
            
            save(viewContext)
            currentPackingList = newPackingList
        }
    }
    
    func toggleSelection(_ filter: String) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    
    func resetSelections() {
        selectedFilters.removeAll()
    }
    
    
    //Generate Packing Categories
    
    @MainActor
    private func generateCategories(from packingList: PackingList, using context: NSManagedObjectContext) -> [Category] {
        
        var selectedCategories: [Category] = []
        
        let defaultCategories = ["Clothing", "Camping Gear", "First Aid"]
        
        // Grab category templates with real Core Data items
        let templates = generateCategoryTemplates(using: context)
        
        let filters = defaultCategories + Array(selectedFilters)
        
        for (index, filter) in filters.enumerated() {
            guard let items = templates[filter] else { continue }
            
            
            // Essential Categories
            let category = Category(
                context: context,
                isExpanded: false,
                name: filter,
                position: index,
                packingList: packingList
            )
            
            items.enumerated().forEach { index, itemTemplate in
               let newItem = Item(
                context: context,
                title: itemTemplate.title ?? "Packing item",
                isPacked: false
               )
                
                newItem.position = Int64(index)
                newItem.category = category
                
                category.addToItems(newItem)
            }
                
            selectedCategories.append(category)
        }
        
        return selectedCategories
    }

    
    func fetchPackingLists() -> [PackingList] {
        let request = NSFetchRequest<PackingList>(entityName: "PackingList")
        return (try? viewContext.fetch(request)) ?? []
    }
}
