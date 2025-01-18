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
                Text(name).foregroundColor(Color.gray)
                Spacer()
                if (content != nil) {
                    Text(content!)
                } else if (linkLabel != nil && linkDestination != nil) {
                    Link(linkLabel!, destination: URL(string: "https://\(linkDestination!)")!)
                    Image(systemName: "arrow.up.right.square").foregroundColor(.pink)
                } else {
                    EmptyView()
                }
            }//:HSTACK
        }//:VSTACK
    }
}

#Preview() {
    Group {
        SettingsRowView(name: "Developer", content: "Jessica Parsons")
        SettingsRowView(name: "Website", linkLabel: "My website", linkDestination: "jessicaparsons.dev")
    }
}

