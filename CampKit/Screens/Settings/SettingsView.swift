//
//  SettingsView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/15/25.
//

import SwiftUI

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case fahrenheit = "Fahrenheit (°F)"
    case celsius = "Celsius (°C)"

    var id: String { self.rawValue }
}


struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(StoreKitManager.self) private var storeKitManager
    //Placeholder
    @AppStorage("temperatureUnit") private var temperatureUnit = TemperatureUnit.fahrenheit.rawValue
    @AppStorage("successEmoji") private var successEmoji: String = "🔥"
    
    @State var isProUnlocked: Bool = false
    @State private var isPickerPresented = false
    @State private var isUpgradeToProPresented: Bool = false
    
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
        
    private let options = TemperatureUnit.allCases
    
    let allEmojis: [String] = [
        "🔥", "🎉", "🏕", "✨", "🌈",
        "🌟", "💯", "🍾", "🥳", "🚀",
        "🎯", "🌞", "🧭", "🪵", "🦉",
        "🌄", "🪂", "🗺", "🎶",
        "☀️", "🌙", "🎒", "🛶",
        "🎣", "🧗", "⛺️", "🪓",
        "🌲", "🌳", "🌿", "🍃", "🍂",
        "🗻", "🥾"
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 44), spacing: 12)
    ]

  
    var body: some View {

            ScrollView(.vertical, showsIndicators: false){
                VStack(spacing: Constants.verticalSpacing){
                    //MARK: - SECTION 1
                    Group {
                    GroupBox(
                        label:
                            SettingsLabelView(labelText: "CampKit", labelImage: "info.circle")
                    )   {
                        Divider().padding(.vertical, 4)
                        HStack(alignment: .center, spacing: 10) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .cornerRadius(9)
                            Text("CampKit is a passion project that helps you build smart packing lists for your trips with weather-based suggestions. Happy camping! 🌲🏕️")
                                .font(.footnote)
                        }//:HSTACK
                        
                    }
                    
                    //MARK: - TEMPERATURE
                    GroupBox(
                        label: SettingsLabelView(labelText: "Temperature", labelImage: "thermometer.high")
                    ) {
                        LazyVStack {
                            ForEach(options, id: \.self) { option in
                                Divider().padding(.vertical, 4)
                                HStack {
                                    Text(option.rawValue)
                                    Spacer()
                                    if option.rawValue == temperatureUnit {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color.customSage)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    temperatureUnit = option.rawValue
                                    HapticsManager.shared.triggerLightImpact()
                                }
                                
                            }//:FOREACH
                            .contentShape(Rectangle())
                        }//:LAZYVSTACK
                        
                    }
                    //MARK: - PRO FEATURES
                        
                        GroupBox(
                            label: SettingsLabelView(labelText: "Pro Features", labelImage: "star.circle")
                        ) {
                            VStack(alignment: .leading) {
                                
                                //MARK: - PURCHASE PRO
                                
                                if !storeKitManager.isUnlimitedListsUnlocked {
                                    Divider().padding(.vertical, 4)
                                    
                                    HStack {
                                        Text("Unlock Unlimited Lists")
                                        Image(systemName: "arrow.up.right.square").foregroundColor(.colorSage)
                                    }//:HSTACK
                                    .padding(.top, Constants.lineSpacing)
                                    .onTapGesture {
                                        isUpgradeToProPresented.toggle()
                                        
                                    }
                                    
                                }
                                
                                //MARK: - CUSTOMIZE BONFIRE
                                
                                Divider().padding(.vertical, 4)

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Customize bonfire")
                                            .foregroundStyle(!storeKitManager.isUnlimitedListsUnlocked ? .primary : .secondary)
                                        Text("Tap to change your celebration emoji")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }//:HSTACK
                                    Spacer()
                                    Button {
                                        if !storeKitManager.isUnlimitedListsUnlocked {
                                            withAnimation {
                                                isPickerPresented.toggle()
                                            }
                                        } else {
                                            isUpgradeToProPresented.toggle()
                                        }
                                    } label: {
                                        Text(successEmoji)
                                            .font(.title)
                                            .padding()
                                            .opacity(!storeKitManager.isUnlimitedListsUnlocked ? 1 : 0.5)
                                        .background(.colorTan)
                                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                                    }
                                    
                                }//:HSTACK
                                if isPickerPresented {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(allEmojis, id: \.self) { emoji in
                                            Text(emoji)
                                                .font(.system(size: 32))
                                                .padding(6)
                                                .frame(width: 44, height: 44)
                                                .background(emoji == successEmoji ? Color.colorTan : Color.clear)
                                                .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                                                .onTapGesture {
                                                    successEmoji = emoji
                                                    HapticsManager.shared.triggerLightImpact()
                                                    withAnimation {
                                                        isPickerPresented = false
                                                    }
                                                }
                                        }//:FOREACH
                                    }//:LAZYVGRID
                                    .padding(.top)
                                    .transition(.scale.combined(with: .opacity))
                                }//:IF PICKER PRESENTED

                                //MARK: - RESTORE PURCHASE
                                Divider().padding(.vertical, 4)
                                Button {
                                    Task {
                                        await storeKitManager.restorePurchases()
                                        restoreMessage = storeKitManager.isUnlimitedListsUnlocked
                                            ? "Your purchase has been restored."
                                            : "No purchases were found to restore."
                                        showRestoreAlert = true
                                    }
                                } label: {
                                    HStack {
                                        Text("Restore in-app purchases")
                                        Image(systemName: "arrow.clockwise")
                                            .font(.caption)
                                    }//:HSTACK
                                }
                                .padding(.top, Constants.lineSpacing)
                                .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                                    Button("OK", role: .cancel) { }
                                } message: {
                                    Text(restoreMessage)
                                }
                                
                            }//:VSTACK
                        }
                    
                    //MARK: - APPLICATION
                    GroupBox(
                        label:
                            SettingsLabelView(labelText: "Application", labelImage: "apps.iphone")
                    ) {
                        
                        SettingsRowView(name: "Development & Design", content: "Jessica Parsons")
                        SettingsRowView(name: "Compatibility", content: "iOS 18.2+")
                        SettingsRowView(name: "Website", linkLabel: "Juniper Creative Co.", linkDestination: "junipercreative.co")
                        SettingsRowView(name: "Portfolio", linkLabel: "GitHub", linkDestination: "github.com/jessicaparsons")
                        SettingsRowView(name: "Version", content: "1.1.0")
                    }
                }//:GROUP
                    .backgroundStyle(Color.colorWhite)

                }//:VSTACK
                .padding(.horizontal)
                .sheet(isPresented: $isUpgradeToProPresented) {
                    UpgradeToProView()
                }
                
            }//:SCROLLVIEW
            .background(Color.colorTan)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        
    }//:BODY
    
    private func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32) * 5 / 9
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(StoreKitManager())
    }
}
