//
//  ListViewModelTests.swift
//  CampKitTests
//
//  Created by Jessica Parsons on 2/9/25.
//

import XCTest
import SwiftData
@testable import CampKit

final class ListViewModelTests: XCTestCase {
    
    private var context: ModelContext!
    private var packingList: PackingList!
    private var viewModel: ListViewModel!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        context = mockContainer.mainContext
        packingList = PackingList(position: 0,
                                  title: "Test Packing List")
        context.insert(packingList)
        viewModel = ListViewModel(modelContext: context, packingList: packingList)
    }
    
    @MainActor
    override func tearDown() {
        context = nil
        print("context: \(String(describing: context))")
        packingList = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testAddItemSuccess() {
        
        let category = Category(name: "Test Category", position: 0)
        context.insert(category)
        
        viewModel.addItem(to: category, itemTitle: "Backpack")
        
        XCTAssertEqual(category.items.count, 1)
        XCTAssertEqual(category.items.first?.title, "Backpack")
        XCTAssertEqual(category.items.first?.position, 0)
        
        viewModel.addItem(to: category, itemTitle: "Sleeping Bag")
        
        XCTAssertEqual(category.items.count, 2)
        XCTAssertEqual(category.items[1].title, "Sleeping Bag")
        XCTAssertEqual(category.items[1].position, 1)
    }
    

    func testAddNewCategorySuccess() {
        
        /*Test that an item is added correctly to a category.
         Ensure an empty title does not add an item.
         Verify that positions are reassigned properly.
         Check that modelContext.insert(newItem) is called. */
        
        //Given (Arrange) set up the scenario you want to test

        
        let initialCategoriesCount = packingList.categories.count
        
        //When (Act)
        viewModel.addNewCategory(title: "New Category")
        
        //Then (Assert)
        XCTAssertEqual(packingList.categories.count, initialCategoriesCount + 1)
        XCTAssertEqual(packingList.categories.last?.name, "New Category")
        XCTAssertEqual(packingList.categories.last?.position, initialCategoriesCount)
    }
    
    func testDeleteCategorySuccess() {
        //Given

        let category = Category(name: "Sleeping Bag", position: 2, items: [], isExpanded: true)
        
        //When
        viewModel.deleteCategory(category)
        
        //Then
        XCTAssertFalse(viewModel.packingList.categories.contains(where: { $0.id == category.id }))
        
    }
    
    func testExpandAllSuccess() {

        viewModel.globalIsExpanded = false
        let oldUUID = viewModel.globalExpandCollapseAction
        
        viewModel.expandAll()
        
        XCTAssertTrue(viewModel.globalIsExpanded)
        XCTAssertNotEqual(viewModel.globalExpandCollapseAction, oldUUID)
    }


}

//let category = Category(name: "Sleeping Gear", position: newPosition, items: [], isExpanded: true)
