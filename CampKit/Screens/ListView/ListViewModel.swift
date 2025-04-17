//
//  ListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import SwiftUI
import CoreData


final class ListViewModel: ObservableObject {
    
    let viewContext: NSManagedObjectContext
    
    @Published var packingList: PackingList
    
    @Published var item: String = ""
    @Published var globalIsExpanded: Bool = false
    @Published var showPhotoPicker: Bool = false
    @Published var draggedCategory: Category?
    @Published var isConfettiVisible: Bool = false
    @Published var isSuccessfulDuplicationPresented: Bool = false
    
    var allItems: [Item] {
        packingList.sortedCategories.flatMap { $0.sortedItems }
    }
    
    var packedCount: Int {
        allItems.filter { $0.isPacked }.count
    }
    
    var packedRatio: Double {
        allItems.isEmpty ? 0 : Double(packedCount) / Double(allItems.count)
    }
    
    init(viewContext: NSManagedObjectContext, packingList: PackingList) {
        self.viewContext = viewContext
        self.packingList = packingList
    }
    
    //MARK: - MODIFY ITEMS
    
    func addItem(to category: Category, itemTitle: String) {
        guard !itemTitle.isEmpty else { return }
        
            let newItem = Item(
                context: viewContext, title: itemTitle,
                isPacked: false)
            newItem.position = Int64(category.sortedItems.count)
            newItem.category = category
        
            category.addToItems(newItem)
            reassignItemPositions(for: category)
            save(viewContext)
            objectWillChange.send()
    }
    
    //Keeps items arranged when a new item is added to a category
    func reassignItemPositions(for category: Category) {
        
        let sortedItems = category.sortedItems
        for (index, item) in sortedItems.enumerated() {
            item.position = Int64(index)
        }
        
        save(viewContext)
    }
    
    func deleteItem(_ item: Item) {
        guard let category = item.category else {
            print("Error: Item does not belong to a category.")
            return
        }
        
        withAnimation {
            viewContext.delete(item)
            reassignItemPositions(for: category)
        }
    }
    
    //MARK: - MODIFY CATEGORIES
    
    func addNewCategory(title: String) {
        withAnimation {
            // Get the max current position, default to -1 if no categories exist
            let maxPosition = packingList.sortedCategories.map(\.position).max() ?? -1
            
            let newCategory = Category(
                context: viewContext,
                isExpanded: true,
                name: title,
                position: Int(maxPosition + 1)
            )

            newCategory.packingList = packingList
            packingList.addToCategories(newCategory)
            save(viewContext)
            objectWillChange.send()
        }
    }
    
    func reassignCategoryPositions(for packingList: PackingList) {
        let sortedCategories = packingList.sortedCategories
        for (index, category) in sortedCategories.enumerated() {
            category.position = Int64(sortedCategories.count - 1 - index) // max = top
        }
        save(viewContext)
    }
    
    func deleteCategory(_ category: Category) {
        withAnimation {
            
            // Remove the category from the packing list
            packingList.removeFromCategories(category)
            viewContext.delete(category)
            reassignCategoryPositions(for: packingList)
        }
        save(viewContext)
        objectWillChange.send()
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
        var sortedCategories = packingList.sortedCategories

        sortedCategories.move(fromOffsets: source, toOffset: destination)

        for (index, category) in sortedCategories.enumerated() {
            category.position = Int64(sortedCategories.count - 1 - index) // Highest = top
        }

        //packingList.categories = sortedCategories
        save(viewContext)
        objectWillChange.send()
    }
    
    //MARK: - MODIFY LIST
    
    
    func duplicateList() {
        
        let lists = try? viewContext.fetch(PackingList.fetchRequest())
        
        lists?.forEach {
            $0.position += 1
        }
        
        let duplicatedPackingList = PackingList(
            context: viewContext,
            title: (packingList.title ?? Constants.newPackingListTitle) + " Copy",
            position: 0,
            locationName: packingList.locationName,
            locationAddress: packingList.locationAddress,
            latitude: packingList.latitude?.doubleValue,
            longitude: packingList.longitude?.doubleValue,
            elevation: packingList.elevation?.doubleValue
        )
        
        duplicatedPackingList.photo = packingList.photo
        
        // Duplicate categories and items
        for category in packingList.sortedCategories {
            let newCategory = Category(
                context: viewContext,
                id: UUID(),
                name: category.name,
                position: Int(category.position)
            )
            
            for item in category.sortedItems {
                let newItem = Item(
                    context: viewContext,
                    title: item.title ?? "Packing Item",
                    isPacked: item.isPacked)
                newItem.position = item.position
                
                newCategory.addToItems(newItem)
            }
            
            duplicatedPackingList.addToCategories(newCategory)
        }
        
        //Save
        save(viewContext)
        
        print("duplicated packing lists position is: \(duplicatedPackingList.position)")
        
        isSuccessfulDuplicationPresented = true
    }
    
    @MainActor
    func deleteList(dismiss: DismissAction) {
        withAnimation {
            viewContext.delete(packingList)
            save(viewContext)
            dismiss()
        }
    }
    
    
    //MARK: - MODIFY ALL ITEMS
    
    func expandAll() {
        withAnimation {
            packingList.sortedCategories.forEach { $0.isExpanded = true }
        }
        save(viewContext)
    }

    func collapseAll() {
        withAnimation {
            packingList.sortedCategories.forEach { $0.isExpanded = false }
        }
        save(viewContext)
    }
    
    
    var areAllItemsChecked: Bool {
        guard !packingList.isDeleted else { return false }
        return packingList.sortedCategories.allSatisfy { category in
            category.sortedItems.allSatisfy { $0.isPacked }
        }
    }
    
    @MainActor
    func toggleAllItems() {
        if areAllItemsChecked {
            uncheckAllItems()
        } else {
            checkAllItems()
            isConfettiVisible = true
            print("is confetti visible set from toggle all items/check all items: \(isConfettiVisible)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation {
                    self.isConfettiVisible = false
                }
            }
           
        }
        save(viewContext)
    }
    
    func checkAllItems() {
        
        for category in packingList.sortedCategories {
            for item in category.sortedItems {
                item.isPacked = true
            }
        }
        
        save(viewContext)
        objectWillChange.send()
    }

    func uncheckAllItems() {
        for category in packingList.sortedCategories {
            for item in category.sortedItems {
                item.isPacked = false
            }
        }
        save(viewContext)
        objectWillChange.send()
    }
    
    @MainActor
    func togglePacked(for item: Item) {
        withAnimation {
            item.isPacked.toggle()
            save(viewContext)
            objectWillChange.send()
        }
        
        if areAllItemsChecked {
            
            isConfettiVisible = true
            print("are all items checked boolean: \(areAllItemsChecked), then isConfettiVisible: \(isConfettiVisible)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation {
                    self.isConfettiVisible = false
                }
            }
        }
            
    }
    
    func shareList() {
        print("Sharing the list!")
    }
    

    
}

