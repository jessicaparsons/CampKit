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
    
    
    var body: some View {
        VStack(alignment: .leading) {

            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    // MARK: - IMAGE
                    
                    let imageToShow: Image = {
                        if let photoData = packingList.photo, let uiImage = UIImage(data: photoData) {
                            return Image(uiImage: uiImage)
                        } else {
                            return Image(Constants.placeholderBannerPhoto)
                        }
                    }()

                    imageToShow
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                    
                    
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
                
            }//:GEO READER
            .aspectRatio(1, contentMode: .fit)

            //MARK: - LIST INFO
            VStack(alignment: .leading, spacing: 2) {
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
                    .font(.footnote)
                }//:VSTACK
        } //:VSTACK
        
        
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


#if DEBUG
#Preview {
    
    @Previewable @State var isEditing: Bool = false
    let previewStack = CoreDataStack.preview
    
    let list = PackingList.samplePackingList(context: previewStack.context)
    
    HomeListCardView(
        viewModel: HomeListViewModel(viewContext: previewStack.context),
        packingList: list,
        isEditing: $isEditing
    )
    .frame(width:200, height:200)
}
#endif
