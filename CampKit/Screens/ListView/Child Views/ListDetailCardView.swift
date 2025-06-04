//
//  ListDetailView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/2/25.
//

import SwiftUI

struct ListDetailCardView: View {
    @ObservedObject var viewModel: ListViewModel
    @State private var isLocationPresented: Bool = false
    @State private var isCalendarPresented: Bool = false
    
    @State private var tempStartDate: Date? = nil
    @State private var tempEndDate: Date? = nil
    
    //Map Options
    @State private var showMapOptions = false
    let locationQuery = "1 Infinite Loop, Cupertino, CA"
        
    var body: some View {
        //MARK: - LIST NAME
        VStack(spacing: 15) {
            HStack {
                TextField("List Title", text: Binding(
                    get: { viewModel.packingList.title ?? Constants.newPackingListTitle },
                    set: { viewModel.packingList.title = $0 }
                ))
                .multilineTextAlignment(.center)
                .font(.title2.weight(.bold))
                .lineLimit(3)
                .truncationMode(.tail)
                    
            }//:HSTACK
            
            
            //MARK: - PROGRESS BAR
                ProgressBarView(
                    viewModel: viewModel,
                    packedRatio: viewModel.packedRatio,
                    packedCount: viewModel.packedCount,
                    allItems: viewModel.allItems
                )

            
            Grid(alignment: .top, horizontalSpacing: 20) {
                
                //MARK: - DATE AND LOCATION
                GridRow {
                    
                    listDates
                    
                    listLocation
                    
                }//:GRID ROW
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondary)
                
            }//:GRID
            
        }//:VSTACK
        .padding(.vertical, 30)
        .padding(.horizontal, Constants.cardSpacing)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.colorWhite)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .sheet(isPresented: $isLocationPresented) {
            VStack {
                LocationSearchView(
                    locationName: $viewModel.packingList.locationName,
                    locationAddress: $viewModel.packingList.locationAddress
                )
                .presentationDetents([.medium, .large])
                .padding(.top)
            }
        }
    }//:BODY
    
    private var listDates: some View {
        HStack(spacing: 5) {
            Image(systemName: "calendar")
                .foregroundColor(.colorSage)
                .font(.footnote)
                .accessibilityLabel("Calendar")
            
            Group {
                if viewModel.packingList.startDate != nil && viewModel.packingList.endDate != nil {
                    Text(viewModel.formattedDateRange)
                        .fixedSize(horizontal: true, vertical: false)
                } else {
                    
                    Text("Anytime")
                }
            }
            
        }//:HSTACK
        .onTapGesture {
            tempStartDate = viewModel.packingList.startDate ?? nil
            tempEndDate = viewModel.packingList.endDate ?? nil
            isCalendarPresented = true
        }
        .sheet(isPresented: $isCalendarPresented) {
            DatePickerView(
                startDate: $tempStartDate,
                endDate: $tempEndDate,
            ) {
                viewModel.updateDates(start: tempStartDate, end: tempEndDate)
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    
    
    private var listLocation: some View {
        HStack(alignment: .top, spacing: 5) {
           
            Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.colorSage)
                    .offset(y: 1)
                    .accessibilityLabel("Open Location Details")
            
            if let locationName = viewModel.packingList.locationName {
               Text(locationName)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .lineSpacing(-2)
                    .multilineTextAlignment(.leading)
            } else {
                Text("No Location Set")
            }
            
            
        }//:HSTACK
        .onTapGesture {
            showMapOptions = true
        }
        .confirmationDialog("Location Details", isPresented: $showMapOptions, titleVisibility: .visible) {
            
            //EDIT LOCATION
            Button("Edit Location") {
                isLocationPresented = true
            }
            .accessibilityHint("Edit the location of this list")
            
            //MAP OPTIONS IF LOCATION IS SET
            if let locationName = viewModel.packingList.locationName,
               let locationAddress = viewModel.packingList.locationAddress
            {
                
                //CLEAR LOCATION
                Button("Clear Location") {
                    viewModel.packingList.locationName = nil
                }
                .accessibilityHint("Clear the location of this list")
                
                Button("Open in Apple Maps") {
                    openInAppleMaps(query: locationName + ", " + locationAddress)
                }
                .accessibilityHint("Open the location in Apple Maps")
                
                Button("Open in Google Maps") {
                    openInGoogleMaps(query: locationName + ", " + locationAddress)
                }
                .accessibilityHint("Open the location in Google Maps")
                
                Button("Cancel", role: .cancel) {}
                    .accessibilityHint("Close")
            }//:IF
        }//:CONFIRMATION DIALOGUE
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


#if DEBUG
#Preview {

    @Previewable @State var isLocationSearchOpen: Bool = false
    let context = CoreDataStack.preview.context
    
    let list = PackingList.samplePackingList(context: context)
        
    ZStack {
        
        Color(.black)
            .ignoresSafeArea()
        ListDetailCardView(viewModel: ListViewModel(viewContext: context, packingList: list))
        
    }
}
#endif
