//
//  PopUpBoxView.swift
//  CampKit
//
//  Created by Jessica Parsons on 4/4/25.
//

import SwiftUI

struct PopUpBoxView: View {
    
    @Binding var isPresented: Bool
    let title: String
    let subtitle: String
    let buttonText: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
                .onAppear() {
                    HapticsManager.shared.triggerSuccess()
                }
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.headline)
                    .padding(.top)
                
                Text(subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Divider()
                
                Button(buttonText) {
                    withAnimation {
                        isPresented = false
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .padding(.horizontal)
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            .padding(.horizontal, 40)
            .transition(.scale.combined(with: .opacity))
        }//:ZSTACK
    }
}
