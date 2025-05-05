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
                if colorScheme == .dark {
                    
                    LinearGradient(
                        colors: [Color.colorSky, Color.colorLilac],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .ignoresSafeArea()
                    
                    Color.black
                        .opacity(0.5)
                        .blendMode(.overlay)
                        .ignoresSafeArea()
                    
                } else {
                    //LIGHT MODE
                    
                    LinearGradient(
                        colors: [Color.colorGold, Color.colorSage, Color.colorSky, Color.colorSky],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .ignoresSafeArea()
                }
                    
                VStack(spacing: Constants.cardSpacing) {
                Spacer()
                //MARK: - TITLE
//                Image("tentIcon")
//                    .resizable()
//                    .frame(width: 120, height: 120)
                VStack(alignment: .center) {
                    Text("Upgrade to Pro")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Unlock all features for just $2.99")
                }//:VSTACK
                
                //MARK: - WHAT'S INCLUDED
                GroupBox {
                    VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                        ProFeaturesListItemView(title: "Unlimited Packing Lists", description: "Create and manage as many lists as you need for every trip.")
                        ProFeaturesListItemView(title: "Success Customization", description: "Swap the default bonfire with your own emoji to celebrate completed lists 🔥")
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
                    .padding(.vertical)
                    .padding(.horizontal, Constants.horizontalPadding)
                }//:GROUPBOX
                .padding(.horizontal, Constants.horizontalPadding)
                .backgroundStyle(Color.colorWhite)
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
#if DEBUG
#Preview {
    @Previewable @Bindable var storeKitManager = StoreKitManager()
    
    UpgradeToProView()
        .environment(storeKitManager)
}
#endif
