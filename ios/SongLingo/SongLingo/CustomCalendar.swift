//
//  CustomCalendar.swift
//  SongLingo
//
//  Created by Jaci on 4/20/26.
//

import SwiftUI

struct CustomCalendar: View {
    @State private var displayedMonth: Date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
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
                
                    let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    HStack(spacing: 0) {
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

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        ForEach(daysForDisplay, id: \.self) { date in
                            if let date = date {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color.pink.opacity(0.3))
                                    .cornerRadius(8)
                            } else {
                                //Empty space
                                Text("")
                                    .frame(maxWidth: .infinity, minHeight: 40)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }
    
    var daysForDisplay: [Date?] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)
        //Total days in month
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
    CustomCalendar()
}
