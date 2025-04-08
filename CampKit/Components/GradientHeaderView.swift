//
//  GradientHeaderView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/5/25.
//

import SwiftUI
import SwiftData

struct GradientHeaderView: View {
    
    let label: String
    @Binding var editMode: EditMode
    let onAdd: () -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
             LinearGradient(colors: [.customGold, .customSage, .customSky, .customLilac], startPoint: .bottomLeading, endPoint: .topTrailing)
                 
             HStack{
                 Text(label)
                     .font(.system(size: Constants.titleFont, weight: .bold, design: .default))
                     .foregroundColor(.black)
                 Spacer()
                 HStack(spacing: Constants.verticalSpacing) {
                     if editMode == .inactive {
                         // REARRANGE BUTTON
                         Button {
                             editMode = (editMode == .active) ? .inactive : .active
                         } label: {
                             Image(systemName: "arrow.up.and.down.text.horizontal")
                                 .font(.body)
                         }
                         // ADD BUTTON
                         Button {
                             onAdd()
                             
                         } label: {
                             Image(systemName: "plus")
                                 .font(.title2)
                         }
                     } else {
                         Button {
                             editMode = (editMode == .active) ? .inactive : .active
                         } label: {
                             Text("Done")
                                .font(.body)
                         }
                     }
                 }//:HSTACK
                 .foregroundStyle(.black)
             }//:HSTACK
             .padding(.top, Constants.navSpacing)
             .padding(.horizontal)
         }//:ZSTACK
         .ignoresSafeArea()
         .frame(height: Constants.gradientBannerHeight)
    }
}

#Preview {
    
    @Previewable @State var editMode: EditMode = .inactive
    
    GradientHeaderView(label: "Howdy, Camper!", editMode: $editMode, onAdd: { print("Added something") })
}
