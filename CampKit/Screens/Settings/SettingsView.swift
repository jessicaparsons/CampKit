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
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(StoreKitManager.self) private var storeKitManager
    //Placeholder
    @AppStorage("temperatureUnit") private var temperatureUnit = TemperatureUnit.fahrenheit.rawValue
    @AppStorage("successEmoji") private var successEmoji: String = "🔥"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State var isProUnlocked: Bool = false
    @State private var isPickerPresented = false
    @State private var isUpgradeToProPresented: Bool = false
    
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var isExpanded: Bool = false
    @State private var isSuccessfulIconRevert: Bool = false
    @State private var isSuccessfulCustomIconSelected: Bool = false
    @State private var isDeleteICloudDataPresented: Bool = false
    @State private var isICloudDataDeleted: Bool = false
    
    private let options = TemperatureUnit.allCases
    
    private let columns = [
        GridItem(.adaptive(minimum: 44), spacing: 12)
    ]
    
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false){
            VStack(alignment: .leading, spacing: Constants.verticalSpacing){
                
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, Constants.largePadding)
                    .padding(.bottom)
                
                Group {
                    
                    
                    //MARK: - DARK/LIGHT MODE
                    
                    GroupBox(
                        label: SettingsLabelView(labelText: "Dark/Light Mode", labelImage: isDarkMode ? "moon.stars" : "sun.max")
                    ) {
                        Divider().padding(.vertical, 4)
                        Toggle(isDarkMode ? "Dark Mode On" :
                                "Dark Mode Off", isOn: $isDarkMode)
                        .toggleStyle(
                            ColoredToggleStyle(
                                label: isDarkMode ? "Dark Mode On" : "Dark Mode Off",
                                onColor: Color.colorToggleOn,
                                offColor: Color.colorToggleOff,
                                thumbColor: Color.colorToggleThumb
                            )
                        )
                        .onChange(of: isDarkMode) {
                            HapticsManager.shared.triggerLightImpact()
                        }
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
                                            .foregroundColor(Color.colorSage)
                                            .accessibilityLabel("Temperature unit is \(option.rawValue)")
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
                            
                            if !storeKitManager.isProUnlocked {
                                Divider().padding(.vertical, 4)
                                
                                HStack {
                                    Text("Unlock Unlimited Lists")
                                    Image(systemName: "arrow.up.right.square").foregroundColor(.colorSage)
                                        .accessibilityLabel("Link to purchase Pro")
                                    ProTag()
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
                                    HStack {
                                        Text("Customize Celebration")
                                        ProTag()
                                    }//:HSTACK
                                    Text("Tap to change your celebration emoji")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }//:VSTACK
                                Spacer()
                                Button {
                                    if storeKitManager.isProUnlocked {
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
                                        .opacity(storeKitManager.isProUnlocked ? 1 : 0.5)
                                        .background(.colorWhiteSands)
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
                                            .background(emoji == successEmoji ? Color.colorWhiteSands : Color.clear)
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
                            Divider().padding(.vertical, 4)
                            
                            // MARK: - SECTION: ICONS
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Custom App Icon")
                                    ProTag()
                                }//:HSTACK
                                Text("Tap to choose your favorite app icon from the collection below")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }//:VSTACK
                            .padding(.top, Constants.lineSpacing)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(alternateAppIcons.indices, id: \.self) { item in
                                            Button {
                                                if isProUnlocked {
                                                    changeAppIcon(to: alternateAppIcons[item])
                                                } else {
                                                    isUpgradeToProPresented.toggle()
                                                }
                                            } label: {
                                                ZStack {
                                                    Image("\(alternateAppIcons[item])-preview")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 80, height: 80)
                                                        .cornerRadius(Constants.cornerRadius)
                                                        .opacity(storeKitManager.isProUnlocked ? 1 : 0.5)
                                                }
                                                
                                            }
                                            .buttonStyle(.borderless)
                                        }
                                    }
                                } //: SCROLL VIEW
                                .padding(.top, Constants.verticalSpacing)
                                
                                Button {
                                    revertAppIcon()
                                } label: {
                                    HStack {
                                        Text("Reset to original icon")
                                        Image(systemName: "tent")
                                            .font(.caption)
                                            .accessibilityLabel("Link to reset icon")
                                            
                                    }//:HSTACK
                                    .foregroundColor(.colorSage)
                                    .fontWeight(.medium)
                                }
                                .padding(.top, 12)
                                .padding(.bottom, Constants.lineSpacing)
                                
                            
                            
                            //MARK: - RESTORE PURCHASE
                            Divider().padding(.vertical, 4)
                            Button {
                                Task {
                                    await storeKitManager.restorePurchases()
                                    restoreMessage = storeKitManager.isProUnlocked
                                    ? "Your purchase has been restored."
                                    : "No purchases were found to restore."
                                    showRestoreAlert = true
                                }
                            } label: {
                                HStack {
                                    Text("Restore in-app purchases")
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                        .accessibilityLabel("Link to restore purchases")
                                }//:HSTACK
                                .foregroundColor(.colorSage)
                            }
                            .padding(.top, Constants.lineSpacing)
                            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                                Button("OK", role: .cancel) { }
                                    .accessibilityHint("OK to dismiss")
                            } message: {
                                Text(restoreMessage)
                            }
                            
                        }//:VSTACK
                    }
                    
                    //MARK: - INFORMATION
                    
                    GroupBox(
                        label: SettingsLabelView(labelText: "Feedback", labelImage: "envelope")
                    ) {
                        Divider()
                            .padding(.vertical, 4)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "star.square.fill")
                                    .foregroundStyle(Color.colorSage)
                                HStack {
                                    Link("Rate CampKit", destination: URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!)
                                        .font(.body)
                                        .foregroundStyle(Color.colorSage)
                                    Image(systemName: "arrow.up.right.square").foregroundColor(Color.colorSage)
                                        .accessibilityLabel("Link to rate CampKit")
                                }//:HSTACK
                                
                            }//:HSTACK
                            .padding(.top, Constants.lineSpacing)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack(alignment: .top) {
                                Image(systemName: "questionmark.app.fill")
                                    .foregroundStyle(Color.colorSage)
                                VStack(alignment: .leading) {
                                    HStack {
                                        Link("Email the Developer", destination: URL(string: "mailto:jess@junipercreative.co?subject=CampKit Feedback")!)
                                            .foregroundStyle(Color.colorSage)
                                        Image(systemName: "arrow.up.right.square").foregroundColor(Color.colorSage)
                                            .accessibilityLabel("Link to email the developer")
                                    }//:HSTACK
                                    
                                    Text("Have a feature idea or ran into an issue? I’d love to hear from you.")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }//:VSTACK
                            }//:HSTACK
                            .padding(.top, Constants.lineSpacing)
                        }
                    }
                    
                    //MARK: - APPLICATION
                    DisclosureGroup(
                        isExpanded: $isExpanded,
                        content: {
                            VStack(alignment: .leading, spacing: 10) {
                                SettingsRowView(name: "Development", content: "Jessica Parsons")
                                SettingsRowView(name: "Design", content: "Lauren Ussery")
                                SettingsRowView(name: "Compatibility", content: "iOS 18.2+")
                                SettingsRowView(name: "Website", linkLabel: "Juniper Creative Co.", linkDestination: "junipercreative.co")
                                SettingsRowView(name: "Portfolio", linkLabel: "GitHub", linkDestination: "github.com/jessicaparsons")
                                SettingsRowView(name: "Version", content: AppInfo.versionWithBuild)
//                                Divider().padding(.vertical, 4)
//                                HStack {
//                                    Text("Delete iCloud Data")
//                                    Image(systemName: "arrow.up.right.square")
//                                }
//                                .foregroundColor(Color.colorSage)
//                                .onTapGesture {
//                                    isDeleteICloudDataPresented = true
//                                }
                            }
                            .padding(.top, 8)
                        },
                        label: {
                            SettingsLabelView(labelText: "App Info", labelImage: "apps.iphone")
                                .tint(.primary)
                        }
                        
                    )
                    .padding()
                    .background(Color.colorWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .confirmationDialog(
                        "Are you sure you want to delete all iCloud Data? This cannot be undone.",
                        isPresented: $isDeleteICloudDataPresented,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            
                            HapticsManager.shared.triggerSuccess()
                            isDeleteICloudDataPresented = false
                            isICloudDataDeleted = true
                        }
                        .accessibilityHint("Delete all iCloud Data")
                        
                        Button("Cancel", role: .cancel) { }
                            .accessibilityHint("Cancel")
                    }
                    .alert("Delete Success", isPresented: $isICloudDataDeleted) {
                        Button("OK", role: .cancel) { }
                            .accessibilityHint("OK")
                    } message: {
                        Text("Your list has been successfully duplicated.")
                    }

                }//:GROUP
                .backgroundStyle(Color.colorWhite)
                                
                
                
                
                
            }//:VSTACK
            .padding(.horizontal)
            .sheet(isPresented: $isUpgradeToProPresented) {
                UpgradeToProView()
            }
            
        }//:SCROLLVIEW
        .background(Color.colorWhiteSandsSheet)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        
        
    }//:BODY
    
    private let allEmojis: [String] = [
        "🔥", "🎉", "🏕", "✨", "🌈",
        "🌟", "💯", "🍾", "🥳", "🚀",
        "🎯", "🌞", "🧭", "🪵", "🦉",
        "🌄", "🪂", "🗺", "🎶",
        "☀️", "🌙", "🎒", "🛶",
        "🎣", "🧗", "⛺️", "🪓",
        "🌲", "🌳", "🌿", "🍃", "🍂",
        "🗻", "🥾"
    ]
    
    private let alternateAppIcons: [String] = (1...24).map { "AppIcon-\($0)" }
    
    private func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32) * 5 / 9
    }
    
    private func changeAppIcon(to iconName: String) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if error != nil {
                print("Failed request to update the app's icon: \(String(describing: error?.localizedDescription))")
            } else {
                isSuccessfulCustomIconSelected = true
            }
        }
        HapticsManager.shared.triggerSuccess()
    }
    
    private func revertAppIcon() {
        UIApplication.shared.setAlternateIconName(nil) { error in
            if let error = error {
                print("Error reverting to default icon: \(error.localizedDescription)")
            }
        }
        HapticsManager.shared.triggerSuccess()
    }
}






#if DEBUG
#Preview {
        SettingsView()
            .environment(StoreKitManager())
    
}
#endif
