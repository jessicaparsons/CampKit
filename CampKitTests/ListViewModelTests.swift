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
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        context = mockContainer.mainContext
        packingList = PackingList(title: "Test Packing List")
        context.insert(packingList)
        
    }

    func testAddNewCategorySuccess() {
        
        /*Test that an item is added correctly to a category.
         Ensure an empty title does not add an item.
         Verify that positions are reassigned properly.
         Check that modelContext.insert(newItem) is called. */
        
        //Given (Arrange) set up the scenario you want to test
        
        let viewModel = ListViewModel(modelContext: context, packingList: packingList)
        
        let initialCategoriesCount = packingList.categories.count
        
        //When (Act)
        viewModel.addNewCategory()
        
        //Then (Assert)
        XCTAssertEqual(packingList.categories.count, initialCategoriesCount + 1)
        XCTAssertEqual(packingList.categories.last?.name, "New Category")
        XCTAssertEqual(packingList.categories.last?.position, initialCategoriesCount)
    }
    
    func testDeleteCategorySuccess() {
        //Given
        let viewModel = ListViewModel(modelContext: context, packingList: packingList)
        let category = Category(name: "Sleeping Bag", position: 2, items: [], isExpanded: true)
        
        //When
        viewModel.deleteCategory(category)
        
        //Then
        XCTAssertFalse(viewModel.packingList.categories.contains(where: { $0.id == category.id }))
        
    }
    
    func testExpandAllSuccess() {
        let viewModel = ListViewModel(modelContext: context, packingList: packingList)
        viewModel.globalIsExpanded = false
        let oldUUID = viewModel.globalExpandCollapseAction
        
        viewModel.expandAll()
        
        XCTAssertTrue(viewModel.globalIsExpanded)
        XCTAssertNotEqual(viewModel.globalExpandCollapseAction, oldUUID)
    }
    
    @MainActor
    override func tearDown() {
        context = nil
        print("context: \(String(describing: context))")
        packingList = nil
        super.tearDown()
    }
    

}

//let category = Category(name: "Sleeping Gear", position: newPosition, items: [], isExpanded: true)
