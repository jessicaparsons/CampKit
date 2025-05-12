//
//  DatePickerView.swift
//  CampKit
//
//  Created by Jessica Parsons on 5/6/25.
//

import SwiftUI

struct DatePickerView: View {
    
    @Environment(\.calendar) var calendar
    @Environment(\.dismiss) var dismiss
    
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    let onTap: () -> Void

    @State private var dates: Set<DateComponents> = []
    let datePickerComponents: Set<Calendar.Component> = [.calendar, .era, .year, .month, .day]
    
    
    var body: some View {
        NavigationStack {
            VStack {
                MultiDatePicker("Select dates", selection: datesBinding)
                    .tint(Color.colorSage)
    
                Color.clear
            }//:VSTACK
            .navigationTitle("Trip Dates")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
            .onAppear {
                if let start = startDate, let end = endDate {
                    var filled = Set<DateComponents>()
                    var current = start
                    while current <= end {
                        filled.insert(calendar.dateComponents(datePickerComponents, from: current))
                        current = calendar.date(byAdding: .day, value: 1, to: current)!
                    }
                    dates = filled
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applyDateRange()
                        onTap()
                        dismiss()
                    }
                }
            }
        }//:NAVSTACK
    }
    
    var datesBinding: Binding<Set<DateComponents>> {
        Binding {
            dates
        } set: { newValue in
            if newValue.isEmpty {
                dates = newValue
            } else if newValue.count > dates.count {
                if newValue.count == 1 {
                    dates = newValue
                } else if newValue.count == 2 {
                    dates = filledRange(selectedDates: newValue)
                } else if let firstMissingDate = newValue.subtracting(dates).first {
                    dates = [firstMissingDate]
                } else {
                    dates = []
                }
            } else if let firstMissingDate = dates.subtracting(newValue).first {
                dates = [firstMissingDate]
            } else {
                dates = []
            }
        }
    }
    
    private func applyDateRange() {
        let selected = dates.compactMap { calendar.date(from: $0) }.sorted()
        startDate = selected.first
        endDate = selected.last
    }
    
    private func filledRange(selectedDates: Set<DateComponents>) -> Set<DateComponents> {
            let allDates = selectedDates.compactMap { calendar.date(from: $0) }
            let sortedDates = allDates.sorted()
            var datesToAdd = [DateComponents]()
            if let first = sortedDates.first, let last = sortedDates.last {
                var date = first
                while date < last {
                    if let nextDate = calendar.date(byAdding: .day, value: 1, to: date) {
                        if !sortedDates.contains(nextDate) {
                            let dateComponents = calendar.dateComponents(datePickerComponents, from: nextDate)
                            datesToAdd.append(dateComponents)
                        }
                        date = nextDate
                    } else {
                        break
                    }
                }
            }
            return selectedDates.union(datesToAdd)
        }
}

#Preview {
    
    @Previewable @State var dates: Set<DateComponents> = [
        DateComponents(year: 2025, month: 5, day: 6),
        DateComponents(year: 2025, month: 5, day: 7),
        DateComponents(year: 2025, month: 5, day: 8),
        DateComponents(year: 2025, month: 5, day: 9),
        DateComponents(year: 2025, month: 5, day: 10)
    ]
    
    @Previewable @State var startDate: Date? = nil
    @Previewable @State var endDate: Date? = nil

    
    DatePickerView(startDate: $startDate, endDate: $endDate, onTap: {})
}
