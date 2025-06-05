//
//  ProTag.swift
//  CampKit
//
//  Created by Jessica Parsons on 6/3/25.
//

import SwiftUI

struct ProTag: View {
    
    @Environment(StoreKitManager.self) private var storeKitManager
    
    var body: some View {
        Text("PRO")
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(storeKitManager.isProUnlocked
                        ?
                        Color.colorSage
                        :
                        Color.colorBloodOrange
                    )
            .foregroundColor(storeKitManager.isProUnlocked
                             ?
                             Color.colorWhiteBackground
                             :
                             Color.white
                         )
            .clipShape(Capsule())
            .accessibilityLabel("Pro feature")
    }
}

#Preview {
    ProTag()
        .environment(StoreKitManager())
}
