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
                        ProFeaturesListItemView(title: "Unlimited Packing Lists", description: "Create and manage as many lists as you need for every trip")
                        ProFeaturesListItemView(
                            title: "Customize Your Trail Icon",
                            description: "Set your style with app icons designed around wild trails and alpine peaks"
                        )
                        ProFeaturesListItemView(
                            title: "Bonfire Customization",
                            description: "Choose your own emoji when you check everything off your list 🔥"
                        )
                                            }//:VSTACK
                    .padding(.vertical, Constants.verticalSpacing)
                    .padding(.horizontal, Constants.verticalSpacing)
                    
                    VStack() {
                        Divider()
                            .padding(.bottom)
                        Text("One time purchase")
                        Button {
                            Task {
                                await                         storeKitManager.purchasePro()
                            }
                        } label: {
                            Text("Upgrade to Pro")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .buttonStyle(BigButton())
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color.colorNeon)
                                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
                        )
                        .accessibilityHint("Upgrade to Pro for unlimited packing lists and customization")
                       
                        
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
                            .foregroundStyle(Color.white)
                            .opacity(0.7)
                            .padding(.top)
                            .accessibilityLabel("Exit")
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
