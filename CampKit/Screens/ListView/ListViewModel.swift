//
//  ListViewModel.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/11/25.
//

import SwiftUI
import CoreData
import CloudKit


final class ListViewModel: ObservableObject {
    
    let viewContext: NSManagedObjectContext
    private let packingListID: NSManagedObjectID
    
    @Published var packingList: PackingList
    
    @Published var item: String = ""
    @Published var globalIsExpanded: Bool = false
    @Published var draggedCategory: Category?
    @Published var isConfettiVisible: Bool = false
    @Published var isSuccessfulDuplicationPresented: Bool = false
    @Published var selectedFilters: Set<String> = []
        
    init(viewContext: NSManagedObjectContext, packingList: PackingList) {
        self.viewContext = viewContext
        self.packingList = packingList
        self.packingListID = packingList.objectID
        
        // Force fetch the latest version to sync cloud changes, fallback to passed-in instance
        if let refreshed = try? viewContext.existingObject(with: packingList.objectID) as? PackingList {
            self.packingList = refreshed
        } else {
            self.packingList = packingList
        }
    }
    
    var allItems: [Item] {
        packingList.sortedCategories.flatMap { $0.sortedItems }
    }
    
    var packedCount: Int {
        allItems.filter { $0.isPacked }.count
    }
    
    var packedRatio: Double {
        allItems.isEmpty ? 0 : Double(packedCount) / Double(allItems.count)
    }
    
    var formattedDateRange: String {
        guard let start = packingList.startDate, let end = packingList.endDate else {
            return "Select Dates"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }
    
    
    //MARK: - REFRESH VIEW
    
    @MainActor
    func refresh() {
        if let updated = try? viewContext.existingObject(with: packingListID) as? PackingList {
            self.packingList = updated
        }
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
            withAnimation(nil) {
                objectWillChange.send()
            }
    }
    
    //Keeps items arranged when a new item is added to a category
    func reassignItemPositions(for category: Category) {
        
        let sortedItems = category.sortedItems
        for (index, item) in sortedItems.enumerated() {
            item.position = Int64(index)
        }
        
        save(viewContext)
    }
    
    func moveItems(_ items: [Item], in category: Category) {
        for (index, item) in items.enumerated() {
            item.position = Int64(index)
        }
        save(viewContext)
        withAnimation {
            objectWillChange.send()
        }
    }
    
    func deleteItem(_ item: Item) {
        guard let category = item.category else {
            print("Error: Item does not belong to a category.")
            return
        }
        
        
        viewContext.delete(item)
        reassignItemPositions(for: category)
        
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
                position: maxPosition + 1
            )

            newCategory.packingList = packingList
            packingList.addToCategories(newCategory)
            save(viewContext)
            withAnimation(nil) {
                objectWillChange.send()
            }
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
    
    
    //MARK: - ADD NEW PRESET CATEGORIES
    
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
    
    
    func addPresetCategories() {
        withAnimation {

            let categories = createPresetCategories(for: packingList, using: viewContext)
            categories.forEach { packingList.addToCategories($0)
                
            }
            save(viewContext)
        }
    }
    
    
    func createPresetCategories(for packingList: PackingList, using context: NSManagedObjectContext) -> [Category] {
        
        var selectedCategories: [Category] = []
        
        // Grab category templates with Core Data items
        let templates = generateCategoryTemplates(using: context)
        
        let filters = Array(selectedFilters)
        
        for filter in filters {
            guard let items = templates[filter] else { continue }
            
            let maxPosition = packingList.sortedCategories.map(\.position).max() ?? -1
            
            
            let category = Category(
                context: context,
                isExpanded: false,
                name: filter,
                position: maxPosition + 1,
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
            latitude: packingList.latitude,
            longitude: packingList.longitude,
            elevation: packingList.elevation,
            startDate: packingList.startDate,
            endDate: packingList.endDate
        )
        
        duplicatedPackingList.photo = packingList.photo
        
        // Duplicate categories and items
        for category in packingList.sortedCategories {
            let newCategory = Category(
                context: viewContext,
                id: UUID(),
                name: category.name,
                position: category.position
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
    
    
    func updateDates(start: Date?, end: Date?) {
        packingList.startDate = start
        packingList.endDate = end
        
        save(viewContext)
        withAnimation(nil) {
            objectWillChange.send()
        }
    }
    
    @MainActor
    func updatePhoto(with image: UIImage) {
        packingList.photo = image.jpegData(compressionQuality: 0.9)
        save(viewContext)
        withAnimation(nil) {
            objectWillChange.send()
        }
    }
    
    
    //MARK: - MODIFY ALL ITEMS
    
    func expandAll() {
        withAnimation {
            packingList.sortedCategories.forEach { $0.isExpanded = true }
        }
        save(viewContext)
        withAnimation(nil) {
            objectWillChange.send()
        }
    }

    func collapseAll() {
        withAnimation {
            packingList.sortedCategories.forEach { $0.isExpanded = false }
        }
        save(viewContext)
        withAnimation(nil) {
            objectWillChange.send()
        }
    }
    
    
    var allItemsAreChecked: Bool {
        guard !packingList.isDeleted else { return false }
        return packingList.sortedCategories.allSatisfy { category in
            category.sortedItems.allSatisfy { $0.isPacked }
        }
    }
    
    @MainActor
    func toggleAllItems() {
        if allItemsAreChecked {
            uncheckAllItems()
        } else {
            checkAllItems()
            isConfettiVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.isConfettiVisible = false
                }
            }
           
        }
        save(viewContext)
    }
    
    @MainActor
    func checkAllItems() {
        
        for category in packingList.sortedCategories {
            for item in category.sortedItems {
                item.isPacked = true
            }
        }
        
        save(viewContext)
        withAnimation(nil) {
            objectWillChange.send()
        }
    }

    @MainActor
    func uncheckAllItems() {
        for category in packingList.sortedCategories {
            for item in category.sortedItems {
                item.isPacked = false
            }
        }
        save(viewContext)
        withAnimation(nil) {
            objectWillChange.send()
        }
    }
    
    @MainActor
    func togglePacked(for item: Item) {
        withAnimation {
            item.isPacked.toggle()
            save(viewContext)
            
            withAnimation(nil) {
                objectWillChange.send()
            }
        }
        
        if allItemsAreChecked {
            
            isConfettiVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.isConfettiVisible = false
                }
            }
        }
            
    }
    //MARK: - SHARING
    
    
    @MainActor
    func loadParticipants(from share: CKShare) -> [CKShare.Participant] {
        return share.participants
    }

    @MainActor
    func fetchLatestShare(for recordID: CKRecord.ID) async throws -> CKShare? {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        return try await withCheckedThrowingContinuation { continuation in
            database.fetch(withRecordID: recordID) { record, error in
                if let share = record as? CKShare {
                    continuation.resume(returning: share)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }



    func exportAsPlainText(packingList: PackingList) -> String {
        var result = "Packing List: \(packingList.title ?? "Untitled")\n\n"
        for category in packingList.sortedCategories {
            let categoryName = category.name
            result += "\(categoryName)\n"
            
            for item in category.sortedItems {
                let itemTitle = item.title ?? "Unnamed Item"
                result += "  〇 \(itemTitle)\n"
            }
            result += "\n"
        }
        return result
    }

 
    func generatePDF(from text: String) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 20
        let textRect = CGRect(x: margin, y: margin, width: pageWidth - 2 * margin, height: pageHeight - 2 * margin)

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineBreakMode = .byWordWrapping
                return style
            }()
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)

        return pdfRenderer.pdfData { context in
            var currentRange = NSRange(location: 0, length: 0)
            let framesetter = CTFramesetterCreateWithAttributedString(attributedText)

            while currentRange.location < attributedText.length {
                context.beginPage()

                let path = CGPath(rect: textRect, transform: nil)
                let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(currentRange.location, 0), path, nil)

                let frameRange = CTFrameGetVisibleStringRange(frame)

                guard let contextRef = UIGraphicsGetCurrentContext() else { return }

                contextRef.textMatrix = .identity
                contextRef.translateBy(x: 0, y: pageHeight)
                contextRef.scaleBy(x: 1.0, y: -1.0)

                CTFrameDraw(frame, contextRef)

                currentRange = NSRange(location: currentRange.location + frameRange.length, length: 0)
            }
        }
    }


    
}

