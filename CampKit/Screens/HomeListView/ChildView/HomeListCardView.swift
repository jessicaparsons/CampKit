//
//  HomeListCardView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/2/25.
//

import SwiftUI

struct HomeListCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: HomeListViewModel
    @ObservedObject var packingList: PackingList
    let onDelete: () -> Void
    @State private var isTargetedSpot: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {

            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    // MARK: - IMAGE
                    
                    //USER IMAGE
                    if let photoData = packingList.photo, let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                        
                    } else {
                        //DEFAULT IMAGE
                        ZStack {
                            Color(Color.colorWhite)
                            Image(systemName: "tent")
                                .font(.system(size: 60))
                                .foregroundColor(Color.colorSecondaryGrey)
                        }//:ZSTACK
                        .ignoresSafeArea()
                    }
                    
                    
                    //MARK: - OVERLAY
                    if allItemsAreChecked {
                        Color.black.opacity(0.25)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.colorNeon)
                            .font(.system(size: 26))
                            .padding()
                    }
                    
                }//:ZSTACK
                .modifier(SwipeActionModifier(
                    isFocused: false,
                    deleteAction: onDelete))
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusRounded))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadiusRounded)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        .animation(.easeInOut(duration: 0.2), value: isTargetedSpot)
                    
                )
                .scaleEffect(isTargetedSpot ? 1.03 : 1.0)
                .shadow(color: isTargetedSpot ? Color.black.opacity(0.25) : .clear, radius: 10, x: 0, y: 4)
                
            }//:GEO READER
            .aspectRatio(1, contentMode: .fit)

            //MARK: - LIST INFO
            VStack(alignment: .leading) {
                    Text(packingList.title ?? Constants.newPackingListTitle)
                        .font(.headline)
                        .foregroundStyle(Color.colorSecondaryTitle)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Group {
                        if let startDate = packingList.startDate, let endDate = packingList.endDate {
                            Text(Date.formattedRange(from: startDate, to: endDate))
                        } else {
                            Text("Anytime")
                        }
                    }//:GROUP
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                }//:VSTACK
        } //:VSTACK
        .draggable(PackingListDragItem(id: packingList.objectID.uriRepresentation()))
        .dropDestination(for: PackingListDragItem.self) { items, _ in
            guard
                let dragItem = items.first,
                let from = viewModel.packingList(for: dragItem.id)
            else { return false }
            withAnimation {
                viewModel.moveItem(from: from, to: packingList)
            }
            HapticsManager.shared.triggerSuccess()
            return true
        } isTargeted: { target in
            isTargetedSpot = target
        }
        
    }//:BODY
    
    var allItemsAreChecked: Bool {
        guard !packingList.isDeleted else { return false }
        
        guard let categories = packingList.categories as? Set<Category>, !categories.isEmpty else { return false }
        
        return categories.allSatisfy { category in
            guard let items = category.items as? Set<Item> else { return false }
            return items.allSatisfy { $0.isPacked }
        }
    }
        
}



#Preview {
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: previewStack.context)
    
    HomeListCardView(
        viewModel: HomeListViewModel(viewContext: previewStack.context),
        packingList: list,
        onDelete: {}
    )
    .frame(width:200, height:200)
}
