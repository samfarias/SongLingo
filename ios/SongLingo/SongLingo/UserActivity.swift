//
//  UserActivity.swift
//  SongLingo
//
//  Created by Jaci on 4/14/26.
//

import SwiftUI

struct UserActivity: View {
//    @State private var date = Date()
    @State private var userActivity: UserActivityData?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.05))
                                .shadow(
                                    color: .black.opacity(1), radius: 4, x: 5, y: 5
                                )
                            
                            VStack {
                                Text("Streak Record")
                                    .bold()
                                
                                Spacer(minLength: 10)
                                
                                Text ("\(userActivity?.streakInfo.longestStreak ?? 0) days")
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                        }
                        
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.05))
                                .shadow(
                                    color: .black.opacity(1), radius: 4, x: 5, y: 5
                                )
                            
                            VStack {
                                Text("Current Streak")
                                    .bold()
                                
                                Spacer(minLength: 10)
                                
                                Text ("\(userActivity?.streakInfo.currentStreak ?? 0) days")
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.05))
                                .shadow(
                                    color: .black.opacity(1), radius: 4, x: 5, y: 5
                                )
                            
                            VStack {
                                Text("Next Milestone")
                                    .bold()
                                
                                Spacer(minLength: 10)
                                
                                Text ("INT days")
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.05))
                            .shadow(
                                color: .black.opacity(1), radius: 4, x: 5, y: 5
                            )
                        
                        CustomCalendar(activeDates: userActivity?.activeDatesSet ?? Set<String>())
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                }
            }
            .navigationTitle("Activity")
            .background(Constants.coastal_mist)
            .task {
                do {
                    self.userActivity = try await fetchUserActivityScreenData(userId: "1")
                } catch {
                    print("Request failed: \(error)")
                }
            }
        }
    }
}

#Preview {
    UserActivity()
}
