//
//  MainView.swift
//  CampKit
//
//  Created by Jessica Parsons on 1/16/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var selection = 0
    @State private var isShowingSettings: Bool = false
    @State private var isShowingQuiz: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                Group {
                    HomeListView(modelContext: modelContext)
                        .tabItem {
                            Image(systemName: "list.bullet")
                        }
                        .tag(0)
                    
                    RemindersView()
                        .tabItem {
                            Image(systemName: "bell")
                        }
                        .tag(1)
                    
                    Spacer()
                        .tabItem {
                            EmptyView()
                        }
                        .tag(2)
                    
                    RestockView()
                        .tabItem {
                            Image(systemName: "arrow.clockwise.square")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .padding(.horizontal)
                        .tabItem {
                            Image(systemName: "gearshape")
                        }
                        .tag(4)
                }//:GROUP
                .toolbarBackground(Color(UIColor.tertiarySystemBackground), for: .tabBar)
            }//:TABVIEW
                
            Button {
                isShowingQuiz = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .symbolRenderingMode(.palette)
                    .font(.system(size: 38))
                    .foregroundStyle(.black, Color(Color.colorNeon))
                    .offset(y: -10)
            }
        }//:ZSTACK
        .ignoresSafeArea(.keyboard) // So the button doesn't move on keyboard appearance
        .onChange(of: selection) { oldValue, newValue in
            if newValue == 2 {
                selection = oldValue // Revert to the previous tab
            }
        }
//        .sheet(isPresented: $isShowingQuiz) {
//            QuizView(viewModel: QuizViewModel(modelContext: modelContext))
//        }
    }
    
}

#Preview {
    let container = try! ModelContainer(
        for: PackingList.self, Category.self, Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    preloadPackingListData(context: container.mainContext)
    
    return MainView()
        .modelContainer(container)
}

