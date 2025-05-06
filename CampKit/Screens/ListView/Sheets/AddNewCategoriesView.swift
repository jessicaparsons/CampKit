//
//  AddNewCategoriesView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/6/25.
//

import SwiftUI

struct AddNewCategoriesView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ListViewModel
    @Environment(\.managedObjectContext) private var viewContext

    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                
                VStack(alignment: .leading, spacing: Constants.cardSpacing) {
                    
                    //                Text("Select to add more preset categories to your list")
                    //                    .multilineTextAlignment(.leading)
                    //                    .font(.subheadline)
                    
                    
                    //MARK: - PARTICIPANTS
                    
                    HStack(alignment:.bottom) {
                        Text("Who's going?")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.addParticipants
                    )
                    
                    
                    //MARK: - DEFAULTS
                    
                    HStack {
                        Text("Essentials")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.defaults
                    )
                    
                    
                    //MARK: - ACTIVITIES
                    
                    
                    HStack {
                        Text("Activities")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.activities
                    )
                    
                    
                    //MARK: - WEATHER
                    
                    HStack {
                        Text("Weather")
                            .font(.footnote)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.addWeatherConditions
                    )
                    
                    
                    //MARK: - ADD BUTTON
                    Button("Add") {
                        
                        viewModel.addPresetCategories()
                        HapticsManager.shared.triggerSuccess()
                        viewModel.objectWillChange.send()
                        viewModel.selectedFilters = []
                        dismiss()
                    }
                    .buttonStyle(BigButtonWide())
                    
                }//:VSTACK
                .navigationTitle("Add Categories")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewModel.selectedFilters = []
                            dismiss()
                        }
                    }
                }//:TOOLBAR
                
            }//:SCROLLVIEW
        }//:NAVIGATIONSTACK
        
    }
}

#Preview {
    
    let previewStack = CoreDataStack.preview
    
    NavigationStack {
        AddNewCategoriesView(viewModel: ListViewModel(viewContext: previewStack.context, packingList: PackingList.samplePackingList(context: previewStack.context)))
    }
}
