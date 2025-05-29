//
//  UpgradeToProView.swift
//  CampKit
//
//  Created by Jessica Parsons on 2/21/25.
//

import SwiftUI

struct UpgradeToProView: View {
    
    @Environment(StoreKitManager.self) private var storeKitManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .center) {
                
                Image("pro-camp")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                VStack(spacing: Constants.cardSpacing) {
                Spacer()
                //MARK: - TITLE

                // Title
                    VStack(spacing: Constants.verticalSpacing) {
                        HStack(spacing: 4) {
                            Text("Upgrade to")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("Pro")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .background(Color.colorBloodOrange)
                                .clipShape(Rectangle())
                        }
                        Text("Unlock all features for just $2.99")
                            .foregroundStyle(.white)
                            .font(.headline)
                    }//:VSTACK
                
                //MARK: - WHAT'S INCLUDED
                GroupBox {
                    VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                        ProFeaturesListItemView(title: "Unlimited Packing Lists", description: "Create and manage as many lists as you need for every trip.")
                        ProFeaturesListItemView(title: "Cloud Sharing", description: "Easily collaborate on your packing lists with family and friends across devices.")
                        ProFeaturesListItemView(title: "Personalize Your App", description: "Choose from cool custom designed app icons and your own emoji for completed lists 🔥")
                    }//:VSTACK
                    .padding(.vertical, Constants.verticalSpacing)
                    .padding(.horizontal, Constants.verticalSpacing)
                    
                    VStack() {
                        Divider()
                            .padding(.bottom)
                        Text("One time purchase")
                        Button {
                            Task {
                                await                         storeKitManager.purchaseUnlimitedLists()
                                
                            }
                        } label: {
                            Text("Upgrade to Pro")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .buttonStyle(BigButton())
                        
                    }//:VSTACK
                    .padding(.vertical, 5)
                    .padding(.horizontal, Constants.horizontalPadding)
                }//:GROUPBOX
                .padding(.horizontal, Constants.horizontalPadding)
                .backgroundStyle(Color.colorWhiteSands)
                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                
                //MARK: - BUTTON
                
                Spacer()
            }//:VSTACK
        }//:ZSTACK
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.regularMaterial)
                            .padding(.top)
                    }
                }
            }
        }//:NAVIGATION STACK
        
    }
}
#if DEBUG
#Preview {
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    
    UpgradeToProView()
        .environment(storeKitManager)
}
#endif
