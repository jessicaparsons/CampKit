//
//  SettingsRowView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/15/25.
//

import SwiftUI

struct SettingsRowView: View {
    
    var name: String
    var content: String? = nil
    var linkLabel: String? = nil
    var linkDestination: String? = nil
    
    var body: some View {
        VStack {
            Divider().padding(.vertical, 4)
            HStack {
                Text(name)
                    .foregroundColor(Color.secondary)
                Spacer()
                if (content != nil) {
                    Text(content!)
                } else if (linkLabel != nil && linkDestination != nil) {
                    Link(linkLabel!, destination: URL(string: "https://\(linkDestination!)")!)
                        .foregroundColor(Color.colorSage)
                    Image(systemName: "arrow.up.right.square").foregroundColor(Color.colorSage)
                        .accessibilityLabel("Link to \(linkLabel!)")
                } else {
                    EmptyView()
                }
            }//:HSTACK
        }//:VSTACK
    }
}

#if DEBUG
#Preview() {
    Group {
        SettingsRowView(name: "Developer", content: "Jessica Parsons")
        SettingsRowView(name: "Website", linkLabel: "My website", linkDestination: "jessicaparsons.dev")
    }
}
#endif
