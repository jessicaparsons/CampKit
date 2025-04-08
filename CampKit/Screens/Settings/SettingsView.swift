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
    //Placeholder
    @AppStorage("temperatureUnit") private var temperatureUnit = TemperatureUnit.fahrenheit.rawValue
    private let options = TemperatureUnit.allCases

  
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
                    
                    //MARK: - SECTION 2
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
                                }
                                
                            }//:FOREACH
                            .contentShape(Rectangle())
                        }//:LAZYVSTACK
                        
                    }
                    
                    //MARK: - SECTION 3
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
    }
}
