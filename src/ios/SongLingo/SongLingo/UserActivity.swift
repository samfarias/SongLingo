//
//  UserActivity.swift
//  SongLingo
//
//  Created by Jaci on 4/14/26.
//

import SwiftUI

struct UserActivity: View {
    @State private var userActivity: UserActivityData?

    var body: some View {
        let currentStreak = userActivity?.streakInfo.currentStreak ?? 0
        let nextMilestone = currentStreak + 5
        
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                                .shadow(
                                    color: .black.opacity(1), radius: 4, x: 5, y: 5
                                )
                            
                            VStack {
                                Text("Streak Record")
                                    .bold()
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer(minLength: 10)
                                
                                Text ("\(userActivity?.streakInfo.longestStreak ?? 0) days")
                                    .foregroundColor(.white.opacity(0.9))
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                        }
                        
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                                .shadow(
                                    color: .black.opacity(1), radius: 4, x: 5, y: 5
                                )
                            
                            VStack {
                                Text("Current Streak")
                                    .bold()
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer(minLength: 10)
                                
                                Text ("\(userActivity?.streakInfo.currentStreak ?? 0) days")
                                    .foregroundColor(.white.opacity(0.9))
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.15))
                                .shadow(
                                    color: .black.opacity(1), radius: 4, x: 5, y: 5
                                )
                            
                            VStack {
                                Text("Next Milestone")
                                    .bold()
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer(minLength: 10)
                                
                                Text ("\(nextMilestone) days")
                                    .foregroundColor(.white.opacity(0.9))
                                
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .shadow(
                                color: .black.opacity(1), radius: 4, x: 5, y: 5
                            )
                        
                        CustomCalendar(activeDates: userActivity?.activeDatesSet ?? Set<String>())
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Streak")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.150, green: 0.155, blue: 0.425),
                            Color(red: 0.275, green: 0.295, blue: 0.650),
                            Color(red: 0.230, green: 0.230, blue: 0.560)


                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(0..<150, id: \.self) { _ in
                                Circle()
                                    .fill(.white)
                                    .frame(width: CGFloat.random(in: 1.5...3), height: CGFloat.random(in: 1.5...3))
                                    .opacity(Double.random(in: 0.1...0.9))
                                    .position(
                                        x: CGFloat.random(in: 0...geometry.size.width),
                                        y: CGFloat.random(in: 0...geometry.size.height)
                                    )
                            }
                            
                            ForEach(0..<10, id: \.self) { i in
                                Image(systemName: i % 2 == 0 ? "sparkles" : "star.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: CGFloat.random(in: 10...15)))
                                    .opacity(Double.random(in: 0.5...0.7))
                                    .shadow(color: .white.opacity(0.3), radius: 3)
                                    .position(
                                        x: CGFloat.random(in: 0...geometry.size.width),
                                        y: CGFloat.random(in: 0...geometry.size.height)
                                    )
                            }
                        }
                    }
                    
                    VStack {
                        RadialGradient(
                            colors: [
                                Color.indigo.opacity(0.35),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: -105, y: -30)
                        
                        Spacer(minLength: 0.2)
                        
                        RadialGradient(
                            colors: [
                                Color.indigo.opacity(0.25),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: 95, y: -10)
                    }
                }
            )
            .task {
                do {
                    self.userActivity = try await NetworkManager.shared.fetchUserActivityScreenData()
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
