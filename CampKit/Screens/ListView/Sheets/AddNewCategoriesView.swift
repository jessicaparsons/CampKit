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
                
                VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                    
                    //MARK: - PARTICIPANTS
                    
                    HStack(alignment:.bottom) {
                        Text("Who's going?")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.addParticipants
                    )
                    .padding(.bottom)
                    
                    
                    //MARK: - DEFAULTS
                    
                    HStack {
                        Text("Essentials")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.defaults
                    )
                    .padding(.bottom)
                    
                    //MARK: - ACTIVITIES
                    
                    
                    HStack {
                        Text("Activities")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.activities
                    )
                    .padding(.bottom)
                    
                    //MARK: - WEATHER
                    
                    HStack {
                        Text("Weather")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                    
                    ChipSectionView(
                        selectedFilters: $viewModel.selectedFilters,
                        preferenceCategory: ChoiceOptions.addWeatherConditions
                    )
                    .padding(.bottom)
                    
                    //MARK: - ADD BUTTON
                    Button("Add") {
                        
                        viewModel.addPresetCategories()
                        HapticsManager.shared.triggerSuccess()
                        withAnimation(nil) {
                            viewModel.objectWillChange.send()
                        }
                        viewModel.selectedFilters = []
                        dismiss()
                    }
                    .buttonStyle(BigButtonWide())
                    .padding(.bottom, Constants.bodyPadding)
                    .accessibilityHint("Add the selected categories to your list")
                    
                    
                }//:VSTACK
                .navigationTitle("Add Categories")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewModel.selectedFilters = []
                            dismiss()
                        }
                        .accessibilityHint("Cancel adding categories")
                    }
                }//:TOOLBAR
                
            }//:SCROLLVIEW
            .padding()
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .bottom)
        }//:NAVIGATIONSTACK
        
    }
}
#if DEBUG
#Preview {
    
    let previewStack = CoreDataStack.preview
    
    NavigationStack {
        AddNewCategoriesView(viewModel: ListViewModel(viewContext: previewStack.context, packingList: PackingList.samplePackingList(context: previewStack.context)))
    }
}
#endif
