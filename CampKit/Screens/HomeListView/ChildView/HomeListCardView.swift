//
//  HomeListCardView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/2/25.
//

import SwiftUI

struct HomeListCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var viewModel: HomeListViewModel
    let packingList: PackingList
    let onDelete: () -> Void
    @State private var isTargetedSpot: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                ZStack {
                    // MARK: - USER IMAGE
                    if let photoData = packingList.photo, let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1/1, contentMode: .fit)
                            .modifier(SwipeActionModifier(
                                isFocused: false,
                                deleteAction: onDelete))
                            .cornerRadius(Constants.cornerRadiusRounded)
                            
                            
                    } else {
                        //MARK: - DEFAULT IMAGE
                        ZStack {
                            Color(Color.colorWhite)
                            Image(systemName: "tent")
                                .font(.system(size: 60))
                                .foregroundColor(Color.colorSecondaryGrey)
                        }//:ZSTACK
                        .ignoresSafeArea()
                        .modifier(SwipeActionModifier(
                            isFocused: false,
                            deleteAction: onDelete))
                        .cornerRadius(Constants.cornerRadiusRounded)
                    }
                }//:ZSTACK
                .aspectRatio(1/1, contentMode: .fill)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadiusRounded)
                        .stroke(isTargetedSpot ? Color.colorNeon : Color(UIColor.systemGray4), lineWidth: isTargetedSpot ? 2 : 1)
                        .animation(.easeInOut(duration: 0.2), value: isTargetedSpot)

                )
                .scaleEffect(isTargetedSpot ? 1.03 : 1.0)
                .shadow(color: isTargetedSpot ? Color.black.opacity(0.25) : .clear, radius: 10, x: 0, y: 4)
                
            }//:ZSTACK
           
            
            
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
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
