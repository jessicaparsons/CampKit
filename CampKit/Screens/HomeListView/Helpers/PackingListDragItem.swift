//
//  PackingListDragItem.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/11/25.
//

import SwiftUI
import UniformTypeIdentifiers


struct PackingListDragItem: Transferable, Codable {
    let id: URL
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .packingListDragItem)
    }
}

extension UTType {
    static let packingListDragItem = UTType(exportedAs: "co.junipercreative.packingListDragItem")
}
