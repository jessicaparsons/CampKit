//
//  ListDetailView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI

struct ListDetailCardView: View {
    @ObservedObject var viewModel: ListViewModel
    
    //Map Options
    @State private var showMapOptions = false
    let locationQuery = "1 Infinite Loop, Cupertino, CA"
        
    var body: some View {
        //MARK: - LIST NAME
        VStack(spacing: 6) {
            HStack {
                HStack {
                    Spacer()
                    Text(viewModel.packingList.title ?? Constants.newPackingListTitle)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .lineLimit(3)
                        .truncationMode(.tail)
                    Spacer()
                }//:HSTACK
        //MARK: - LIST LOCATION
            }//:HSTACK
            
            listLocation
            
        //MARK: - PROGRESS BAR
            progressBar
            
        }//:VSTACK
        .padding(.vertical, Constants.cardSpacing)
        .padding(.horizontal, Constants.cardSpacing)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.colorWhite)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }//:BODY
    
    
    private var listLocation: some View {
        HStack {
            Text(viewModel.packingList.locationName ?? "No Location Set")
                .multilineTextAlignment(.center)
            
            if viewModel.packingList.locationName != nil {
                Image(systemName: "arrow.up.right.square").foregroundColor(.colorSage)
            }
        }//:HSTACK
        .onTapGesture {
            if viewModel.packingList.locationName != nil {
                showMapOptions = true
            }
        }
        .confirmationDialog("Open location in:", isPresented: $showMapOptions, titleVisibility: .visible) {
            
            if let locationName = viewModel.packingList.locationName,
               let locationAddress = viewModel.packingList.locationAddress
            {
                Button("Apple Maps") {
                    openInAppleMaps(query: locationName + ", " + locationAddress)
                }
                
                Button("Google Maps") {
                    openInGoogleMaps(query: locationName + ", " + locationAddress)
                }
                
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            HStack {
                Spacer()
                HStack {
                    ProgressView(value: viewModel.packedRatio)
                        .progressViewStyle(LinearProgressViewStyle(tint: .colorNeon))
                        .animation(.easeInOut, value: viewModel.packedRatio)
                }//:HSTACK
                .frame(width: geo.size.width * 0.75)
                
                HStack {
                    Text("\(viewModel.packedCount)/\(viewModel.allItems.count)")
                        .font(.subheadline)
                    Spacer()
                }//:HSTACK
                .frame(width: geo.size.width * 0.25)
                Spacer()
                                    
            }//:HSTACK
        }//:GEOMETRY READER
        .padding(.horizontal, Constants.horizontalPadding)
        .frame(height: 20)
    }
    
    
    //MARK: - FUNCTIONS
    private func openInAppleMaps(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(encodedQuery)") {
            UIApplication.shared.open(url)
        }
    }

    private func openInGoogleMaps(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "comgooglemaps://?q=\(encodedQuery)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let fallbackURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(encodedQuery)") {
            UIApplication.shared.open(fallbackURL)
        }
    }
    
    
}//:STRUCT


//#if DEBUG
//#Preview {
//
//    let context = PersistenceController.preview.persistentContainer.viewContext
//    
//    let samplePackingList = PackingList.samplePackingList(context: context)
//        
//    ZStack {
//        
//        Color(.black)
//            .ignoresSafeArea()
//        ListDetailCardView(viewModel: ListViewModel(viewContext: context, packingList: samplePackingList))
//        
//    }
//}
//#endif
