//
//  QuizViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/5/25.
//

import SwiftUI
import SwiftData
import CoreLocation

@Observable
final class QuizViewModel {
    
    //MARK: - PROPERTIES
    
    private let modelContext: ModelContext
    
    var selectedFilters: Set<String> = []
    
    var listTitle: String = ""
    var locationName: String?
    var locationAddress: String?
    var latitude: Double?
    var longitude: Double?
    var elevation: Double = 0
    
    //Stores the packing list so the user gets sent to it after creation
    var currentPackingList: PackingList?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    //MARK: - METHODS
    
    @MainActor
    func createPackingList() {
        withAnimation {
            
            // filters the choices to include only the selected items
            // where 'isSelected' is true, then maps the filtered result to an array of their names
            // inserts the choices into the context
            
            let lists = try! modelContext.fetch(FetchDescriptor<PackingList>())

            for list in lists {
                list.position += 1
            }
            
            let newPackingList = PackingList(
                position: 0,
                title: listTitle.isEmpty ? "My Packing List" : listTitle,
                locationName: (locationName == nil) ? nil : locationName,
                locationAddress: (locationAddress == nil) ? nil : locationAddress,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation
            )
            
            //Generate recommended categories and items
            let categories = generateCategories(from: newPackingList)
            newPackingList.categories.append(contentsOf: categories)
            
            newPackingList.categories.last?.isExpanded = true
            
            //Save
            modelContext.insert(newPackingList)
            save(modelContext)
            
            currentPackingList = newPackingList
        }
        
    }
    
    func createBlankPackingList() {
        
        let lists = try! modelContext.fetch(FetchDescriptor<PackingList>())

        for list in lists {
            list.position += 1
        }
        
        withAnimation {
            let newPackingList = PackingList(
                position: 0,
                title: "My Packing List",
                locationName: nil,
                locationAddress: nil,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation
            )
            
            modelContext.insert(newPackingList)
            save(modelContext)
            
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
    private func generateCategories(from packingList: PackingList) -> [Category] {
        
        var selectedCategories: [Category] = []
        
        let defaultCategories = ["Clothing", "Camping Gear", "First Aid"]
        
        
        //Always include essential categories first
        
        for categoryName in defaultCategories {
            if let itemTemplates = categoryTemplates[categoryName] {
                
                //Create the categories
                let category = Category(name: categoryName, position: selectedCategories.count)
                
                //Assign position dynamically and link items to the category
                category.items = itemTemplates.enumerated().map { index, itemTemplate in
                    let newItem = Item(title: itemTemplate.title, isPacked: false)
                    newItem.position = index //Assign a position
                    newItem.category = category //Assign the category
                    
                    return newItem
                }
                
                selectedCategories.append(category)
            }
        }
        
        //Add user selected categories
        
        for filter in selectedFilters {
            if let itemTemplates = categoryTemplates[filter] {
                let category = Category(name: filter, position: selectedCategories.count)
                
                category.items = itemTemplates.enumerated().map { index, itemTemplate in
                    let newItem = Item(title: itemTemplate.title, isPacked: false)
                    newItem.position = index
                    newItem.category = category
                    return newItem
                }
                
                selectedCategories.append(category)
            }
        }
        
        return selectedCategories
    }
}
