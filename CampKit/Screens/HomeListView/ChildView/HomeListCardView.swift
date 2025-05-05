//
//  HomeListCardView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/2/25.
//

import SwiftUI

struct HomeListCardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let packingList: PackingList
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
               // MARK: - USER IMAGE
                if let photoData = packingList.photo, let image = UIImage(data: photoData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1/1, contentMode: .fit)
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
                    .cornerRadius(Constants.cornerRadiusRounded)
                }
            }//:ZSTACK
            .aspectRatio(1/1, contentMode: .fill)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadiusRounded)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
            )
            
            //MARK: - LIST INFO
            
            Text(packingList.title ?? Constants.newPackingListTitle)
                .font(.headline)
                .foregroundStyle(Color.colorSecondaryTitle)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(packingList.dateCreated, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
          
        } //:VSTACK
    }
}

#Preview {
    
    let context = CoreDataStack.shared.context
    
    let list = PackingList.samplePackingList(context: context)
    
    HomeListCardView(packingList: list)
}
