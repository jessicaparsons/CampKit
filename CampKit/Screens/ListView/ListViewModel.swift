//
//  ListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import SwiftUI
import SwiftData

@Observable
final class ListViewModel {
    
    let modelContext: ModelContext
    
    var packingList: PackingList
    
    var item: String = ""
    var globalIsExpanded: Bool = false
    var globalExpandCollapseAction = UUID() // Trigger for animation
    var showPhotoPicker: Bool = false
    var draggedCategory: Category?
    var isConfettiVisible: Bool = false
    var trigger: Int = 0
    var isShowingSuccessfulDuplication: Bool = false
    
    init(modelContext: ModelContext, packingList: PackingList) {
        self.modelContext = modelContext
        self.packingList = packingList
    }
    
    //MARK: - MODIFY ITEMS
    
    func addItem(to category: Category, itemTitle: String) {
        guard !itemTitle.isEmpty else { return }
            let newItem = Item(
                title: itemTitle,
                isPacked: false)
            newItem.position = category.items.count
            newItem.category = category
            category.items.append(newItem)
            modelContext.insert(newItem)
            reassignItemPositions(for: category)
    }
    
    //Keeps items arranged when a new item is added to a category
    func reassignItemPositions(for category: Category) {
        
        let sortedItems = category.items
            .compactMap { $0.position != nil ? $0 : nil }
            .sorted { ($0.position ?? 0) < ($1.position ?? 0) }
        
        for (index, item) in sortedItems.enumerated() {
            item.position = index
        }
        
        save(modelContext)
    }
    
    func deleteItem(_ item: Item) {
        guard let safeItem = item.category else {
            print("Error: Item does not belong to a category.")
            return
        }
        
        withAnimation {
            modelContext.delete(item)
            reassignItemPositions(for: safeItem)
        }
    }
    
    //MARK: - MODIFY CATEGORIES
    
    func addNewCategory(title: String) {
        withAnimation {
            // Get the max current position, default to -1 if no categories exist
            let maxPosition = packingList.categories.map(\.position).max() ?? -1
            
            let newCategory = Category(
                name: title,
                position: maxPosition + 1,
                isExpanded: true
            )

            packingList.categories.append(newCategory)
            modelContext.insert(newCategory)
            save(modelContext)
        }
    }
    
    func reassignCategoryPositions(for packingList: PackingList) {
        let sortedCategories = packingList.categories.sorted(by: { $0.position > $1.position }) // descending
        for (index, category) in sortedCategories.enumerated() {
            category.position = sortedCategories.count - 1 - index // max = top
        }
        save(modelContext)
    }
    
    func deleteCategory(_ category: Category) {
        withAnimation {
            
            // Remove the category from the packing list
            packingList.categories.removeAll { $0.id == category.id }
            modelContext.delete(category)
            reassignCategoryPositions(for: packingList)
        }
        save(modelContext)
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
        var sortedCategories = packingList.categories.sorted(by: { $0.position > $1.position })

        sortedCategories.move(fromOffsets: source, toOffset: destination)

        for (index, category) in sortedCategories.enumerated() {
            category.position = sortedCategories.count - 1 - index // Highest = top
        }

        packingList.categories = sortedCategories
        save(modelContext)
    }
    
    //MARK: - MODIFY LIST
    
    
    func duplicateList() {
        
        let lists = try! modelContext.fetch(FetchDescriptor<PackingList>())
                for list in lists {
                    list.position += 1
                }
        
        let duplicatedPackingList = PackingList(
            position: 0,
            title: packingList.title + " Copy",
            locationName: packingList.locationName,
            locationAddress: packingList.locationAddress,
            latitude: packingList.latitude,
            longitude: packingList.longitude,
            elevation: packingList.elevation
        )
        
        duplicatedPackingList.photo = packingList.photo
        
        // Duplicate categories and items
        for category in packingList.categories {
            let newCategory = Category(
                id: UUID(),
                name: category.name,
                position: category.position)
            for item in category.items {
                let newItem = Item(
                    id: UUID(),
                    title: item.title,
                    isPacked: item.isPacked)
                newItem.position = item.position
                newCategory.items.append(newItem)
            }
            duplicatedPackingList.categories.append(newCategory)
        }
        
        //Save
        modelContext.insert(duplicatedPackingList)
        save(modelContext)
        
        print("duplicated packing lists position is: \(duplicatedPackingList.position)")
        
        isShowingSuccessfulDuplication = true
    }
    
    @MainActor
    func deleteList(dismiss: DismissAction) {
        withAnimation {
            dismiss()

            modelContext.delete(packingList)
            save(modelContext)
            
        }
    }
    
    
    //MARK: - MODIFY ALL ITEMS
    
    func expandAll() {
        withAnimation {
            for category in packingList.categories {
                category.isExpanded = true
            }
        }
        save(modelContext)
    }

    func collapseAll() {
        withAnimation {
            for category in packingList.categories {
                category.isExpanded = false
            }
        }
        save(modelContext)
    }
    
    
    var areAllItemsChecked: Bool {
        guard !packingList.isDeleted else { return false }
        return packingList.categories.allSatisfy { category in
            category.items.allSatisfy { $0.isPacked }
        }
    }
    
    @MainActor
    func toggleAllItems() {
        if areAllItemsChecked {
            uncheckAllItems()
        } else {
            checkAllItems()
            isConfettiVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.trigger += 1
            }
        }
    }
    
    func checkAllItems() {
        for category in packingList.categories {
            for item in category.items {
                item.isPacked = true
            }
        }
        save(modelContext)
    }

    func uncheckAllItems() {
        for category in packingList.categories {
            for item in category.items {
                item.isPacked = false
            }
        }
        save(modelContext)
    }
    
    @MainActor
    func togglePacked(for item: Item) {
        withAnimation {
            item.isPacked.toggle()
            save(modelContext)
        }
        
        if areAllItemsChecked {
            isConfettiVisible = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.trigger += 1
            }
        }
            
    }
    
    func shareList() {
        print("Sharing the list!")
    }
    

    
}

