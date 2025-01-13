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
    @Published var isEditingTitle: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    @Published var showPhotoPicker: Bool = false
    @Published var draggedCategory: Category?

    let hapticFeedback = UINotificationFeedbackGenerator()
    
    init(packingList: PackingList, modelContext: ModelContext) {
        self.packingList = packingList
        self.modelContext = modelContext
    }
    
    func addItem(to category: Category, itemTitle: String) {
        guard !itemTitle.isEmpty else { return }
            let newItem = Item(
                title: itemTitle,
                isPacked: false,
                position: category.items.count,
                category: category)
            category.items.append(newItem)
            modelContext.insert(newItem)
            reassignItemPositions(for: category)
    }
    
    func reassignItemPositions(for category: Category) {
        for (index, item) in category.items.sorted(by: { $0.position < $1.position }).enumerated() {
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
    
    func expandAll() {
        withAnimation {
            globalIsExpanded = true
            globalExpandCollapseAction = UUID()
        }
    }

    func collapseAll() {
        withAnimation {
            globalIsExpanded = false
            globalExpandCollapseAction = UUID()
        }
    }
    
    func deleteList(dismiss: DismissAction) {
        withAnimation {
            
            // Log categories before deletion
            print("Categories before deletion: \(packingList.categories.map { $0.name })")
            
            for category in packingList.categories {
                modelContext.delete(category)
            }
            
            modelContext.delete(packingList)
            saveContext()
            dismiss()
        }
    }
    
    var areAllItemsChecked: Bool {
        packingList.categories.allSatisfy { category in
            category.items.allSatisfy { $0.isPacked }
        }
    }

    func toggleAllItems() {
        if areAllItemsChecked {
            uncheckAllItems()
        } else {
            checkAllItems()
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
    
    func togglePacked(for item: Item) {
            withAnimation {
                item.isPacked.toggle()
                saveContext()
            }
        }
    
    func shareList() {
        print("Sharing the list!")
    }
    
    func packedTextColor(for item: Item) -> Color {
        item.isPacked ? .accentColor : .primary
    }
    
    func packedCircleColor(for item: Item) -> (systemName: String, color: Color) {
            if item.isPacked {
                return ("checkmark.circle.fill", .green)
            } else {
                return ("circle", .gray)
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

