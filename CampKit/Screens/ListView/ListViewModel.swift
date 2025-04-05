//
//  ListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import SwiftUI
import SwiftData

class ListViewModel: ObservableObject {
    
    private let modelContext: ModelContext
    
    @Published var packingList: PackingList
    
    @Published var item: String = ""
    @Published var globalIsExpanded: Bool = false
    @Published var globalExpandCollapseAction = UUID() // Trigger for animation
    @Published var isRearranging: Bool = false
    @Published var showPhotoPicker: Bool = false
    @Published var draggedCategory: Category?
    @Published var isConfettiVisible: Bool = false
    @Published var trigger: Int = 0
    @Published var isShowingDuplicationConfirmation: Bool = false
    
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
        
        saveContext()
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
    
    func addNewCategory() {
        withAnimation {
            let newPosition = packingList.categories.count
            let newCategory = Category(name: "New Category", position: newPosition)
            packingList.categories.append(newCategory)
            modelContext.insert(newCategory)
            reassignCategoryPositions(for: packingList)
        }
    }
    
    func reassignCategoryPositions(for packingList: PackingList) {
        let sortedCategories = packingList.categories.sorted(by: { $0.position < $1.position })
        for (index, category) in sortedCategories.enumerated() {
            category.position = index // Assign new sequential position
        }
        saveContext()
    }
    
    func deleteCategory(_ category: Category) {
        withAnimation {
            
            // Remove the category from the packing list
            packingList.categories.removeAll { $0.id == category.id }
            modelContext.delete(category)
            reassignCategoryPositions(for: packingList)
        }
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
            // Sort categories by position before reordering
        var sortedCategories = packingList.categories.sorted(by: { $0.position < $1.position })
            
            // Perform the move operation
            sortedCategories.move(fromOffsets: source, toOffset: destination)
            
            // Update the original categories array to reflect the new order
            for (index, category) in sortedCategories.enumerated() {
                category.position = index
            }
            packingList.categories = sortedCategories // Update the binding
            
            saveContext()
    }
    
    //MARK: - MODIFY LIST
    
    
    func duplicateList() {
        let duplicatedPackingList = PackingList(
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
        saveContext()
        
        isShowingDuplicationConfirmation = true
    }
    
    @MainActor
    func deleteList(dismiss: DismissAction) {
        withAnimation {
            
            packingList.categories.removeAll()
            
            modelContext.delete(packingList)
            saveContext()
            dismiss()
        }
    }
    
    //When a new list is created, all categories will be collapsed except the first.
    private func expandFirstCategory() {
        
    }
    
    
    //MARK: - MODIFY ALL ITEMS
    
    func expandAll() {
        withAnimation {
            for category in packingList.categories {
                category.isExpanded = true
            }
        }
        saveContext()
    }

    func collapseAll() {
        withAnimation {
            for category in packingList.categories {
                category.isExpanded = false
            }
        }
        saveContext()
    }
    
    
    var areAllItemsChecked: Bool {
        packingList.categories.allSatisfy { category in
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
        saveContext()
    }

    func uncheckAllItems() {
        for category in packingList.categories {
            for item in category.items {
                item.isPacked = false
            }
        }
        saveContext()
    }
    
    @MainActor
    func togglePacked(for item: Item) {
        withAnimation {
            item.isPacked.toggle()
            saveContext()
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
    
    //MARK: - UI
    
    func packedTextColor(for item: Item) -> Color {
        item.isPacked ? Color.secondary : .primary
    }
    
    func packedCircleColor(for item: Item) -> (systemName: String, color: Color) {
            if item.isPacked {
                return ("checkmark.circle.fill", Color.colorSage)
            } else {
                return ("circle", Color.secondary)
            }
    }

    func saveContext() {
        do {
            try modelContext.save()
            print("Packing list and categories deleted successfully.")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
}

