//
//  QuizView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/17/25.
//

import SwiftUI
import SwiftData

struct QuizView: View {

    @StateObject var viewModel: QuizViewModel
    @Binding var isNewListQuizShowing: Bool
    @Binding var isStepOne: Bool
    @Binding var location: String
    
    var body: some View {
        VStack {
            ZStack {
                ScrollView {
                    if isStepOne {
                        QuizPageOneView(viewModel: viewModel, location: $location, isStepOne: $isStepOne)
                            .transition(.move(edge: .leading))
                    } else {
                        QuizPageTwoView(viewModel: viewModel, isStepOne: $isStepOne, location: $location)
                            .transition(.move(edge: .trailing))
                    }
                }
            }//:ZSTACK
            
            Spacer()
            
            VStack {
                ProgressIndicatorView(isStepOne: $isStepOne)
                    .padding(.bottom, Constants.verticalSpacing)
                
                HStack {
                    //Show back button only on step 2
                    if !isStepOne {
                        Button(action: {
                            isStepOne = true
                        }) {
                            Text("Back")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BigButtonWide())
                    }

                    Button(action: {
                        if isStepOne {
                            isStepOne = false
                        } else {
                            //createNewList()
                            isNewListQuizShowing = false
                        }
                    }) {
                        Text(isStepOne ? "Next" : "Create List")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BigButtonWide())
                }
            }
            .padding()
            .padding(.bottom, 20)
        }//VSTACK
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isNewListQuizShowing = false
                    isStepOne = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .tint(Color.accent)
                }
            }
        }
        .onDisappear {
            isStepOne = true
        }
    }//:BODY
    
}




#Preview {
    
    @Previewable @State var isNewListQuizShowing: Bool = true
    @Previewable @State var isStepOne: Bool = true
    @Previewable @State var location: String = "Paris"
    
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    QuizView(viewModel: QuizViewModel(modelContext: container.mainContext), isNewListQuizShowing: $isNewListQuizShowing, isStepOne: $isStepOne, location: $location)
}
