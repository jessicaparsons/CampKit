//
//  UpgradeToProView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/21/25.
//

import SwiftUI

struct UpgradeToProView: View {
    
    @Environment(StoreKitManager.self) private var storeKitManager
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: Constants.cardSpacing) {
                
                //MARK: - TITLE
                Image("tentIcon")
                    .resizable()
                    .frame(width: 120, height: 120)
                VStack(alignment: .center) {
                    Text("Upgrade to Pro")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Unlock all features for just $2.99")
                }//:VSTACK
                
                //MARK: - WHAT'S INCLUDED
                GroupBox {
                    VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                        ProFeaturesListItemView(title: "Unlimited Packing Lists", description: "More descriptive text will go here about it")
                        ProFeaturesListItemView(title: "Dark Mode", description: "More descriptive text will go here about it")
                    }//:VSTACK
                    .padding(.vertical, Constants.verticalSpacing)
                }//:GROUPBOX
                .padding(.horizontal, Constants.horizontalPadding)
                .backgroundStyle(Color.colorTan)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                
                //MARK: - BUTTON
                Spacer()
                VStack(spacing: Constants.verticalSpacing) {
                    Divider()
                    Text("One time purchase")
                    Button {
                        Task {
                            await                         storeKitManager.purchaseUnlimitedLists()

                        }
                    } label: {
                        Text("Upgrade to Pro")
                    }
                    .buttonStyle(BigButton())
                    
                }//:VSTACK
                
            }//:VSTACK
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        storeKitManager.isUpgradeToProShowing = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .tint(Color.accent)
                    }
                }
            }
        }//:NAVIGATION STACK
    }
}

#Preview {
    
    UpgradeToProView()
}
