//
//  ListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import SwiftUI
import SwiftData

class ListViewModel: ObservableObject {
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
    
    init(packingList: PackingList) {
        self.packingList = packingList
    }
    
    func addItem(to category: Category, itemTitle: String, using context: ModelContext) {
        guard !itemTitle.isEmpty else { return }
            let newItem = Item(title: itemTitle, isPacked: false)
            category.items.append(newItem)
            context.insert(newItem)
            saveContext(using: context)
    }
    
    func deleteItem(using context: ModelContext, _ item: Item) {
        withAnimation {
            context.delete(item)
            saveContext(using: context)
        }
    }
    
    func addNewCategory(using context: ModelContext) {
        withAnimation {
            let newPosition = packingList.categories.count
            let newCategory = Category(name: "New Category", position: newPosition)
            packingList.categories.append(newCategory)
            context.insert(newCategory)
            saveContext(using: context)
        }
    }
    
    func deleteCategory(using context: ModelContext, _ category: Category) {
        withAnimation {
            // Remove the category from the packing list
            packingList.categories.removeAll { $0.id == category.id }
            context.delete(category)
            saveContext(using: context)
        }
    }
    
    func moveCategories(from source: IndexSet, to destination: Int, using context: ModelContext) {
        packingList.categories.move(fromOffsets: source, toOffset: destination)
        saveContext(using: context)
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
    
    func deleteList(using context: ModelContext, dismiss: DismissAction) {
        withAnimation {
            
            // Log categories before deletion
            print("Categories before deletion: \(packingList.categories.map { $0.name })")
            
            for category in packingList.categories {
                context.delete(category)
            }
            
            context.delete(packingList)
            saveContext(using: context)
            dismiss()
        }
    }
    
    func checkAll() {
        
    }
    
    func shareList() {
        print("Sharing the list!")
    }
    
    func textColor(for item: Item) -> Color {
        item.isPacked ? .accentColor : .primary
    }

    private func saveContext(using context: ModelContext) {
        do {
            try context.save()
            print("Packing list and categories deleted successfully.")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
}

