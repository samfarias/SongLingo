//
//  CustomCalendar.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct CustomCalendar: View {
    @State private var displayedMonth: Date = Date()
    
    let activeDates: Set<String>
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    headerView
                
                    weekdayLabels
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(daysForDisplay.indices), id: \.self) { index in
                            if let date = daysForDisplay[index] {
                                dateCell(for: date)
                            } else {
                                Color.clear.frame(minHeight: 40)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: goToPreviousMonth) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(monthYearString(for: displayedMonth))
                .font(.title.bold())
            Spacer()
            Button(action: goToNextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
    
    private var weekdayLabels: some View {
        HStack(spacing: 0) {
            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 5)
    }

    @ViewBuilder
    private func dateCell(for date: Date) -> some View {
        let dateKey = formatDate(date)
        let isActive = activeDates.contains(dateKey)
        
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(isActive ? Constants.green : LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .foregroundColor(isActive ? .white : .primary)
            .fontWeight(isActive ? .bold : .regular)
            .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var daysForDisplay: [Date?] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let leadingEmpty = Array<Date?>(repeating: nil, count: weekdayOfFirst - 1)
        let datesInMonth: [Date?] = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
        return leadingEmpty + datesInMonth
    }

    func goToPreviousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    func goToNextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    CustomCalendar(activeDates: [])
}
