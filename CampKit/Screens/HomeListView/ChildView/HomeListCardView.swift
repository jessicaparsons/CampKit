//
//  HomeListCardView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/2/25.
//

import SwiftUI

struct HomeListCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: HomeListViewModel
    @ObservedObject var packingList: PackingList
    
    
    @Binding var isEditing: Bool
    @Binding var isDeleteConfirmationPresented: Bool
    
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
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadiusRounded))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadiusRounded)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    
                )
                .onLongPressGesture {
                    withAnimation {
                        isEditing = true
                        HapticsManager.shared.triggerLightImpact()
                    }
                }
                .overlay(alignment: .topLeading) {
                    if isEditing {
                        Button(action: {
                            isDeleteConfirmationPresented = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "minus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .padding(6)
                            .offset(x: -12, y: -12)
                        }
                    }
                }
                
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
        .confirmationDialog(
            "Are you sure you want to delete this list?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.delete(packingList)
                HapticsManager.shared.triggerSuccess()
                save(viewContext)
            }
            Button("Cancel", role: .cancel) { }
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
    
    @Previewable @State var isEditing: Bool = false
    @Previewable @State var isDeleteConfirmationPresented: Bool = false
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: previewStack.context)
    
    HomeListCardView(
        viewModel: HomeListViewModel(viewContext: previewStack.context),
        packingList: list,
        isEditing: $isEditing, isDeleteConfirmationPresented: $isDeleteConfirmationPresented
    )
    .frame(width:200, height:200)
}
