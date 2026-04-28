//
//  UserActivity.swift
//  SongLingo
//
//  Created by Jaci on 4/14/26.
//

import SwiftUI

struct UserActivity: View {
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pink.opacity(0.3))
                            
                            VStack {
                                Text("Streak Record")
                                    .bold()
                                
                                Spacer(minLength: 10)
                                
                                Text ("INT days")
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                        }
                        
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pink.opacity(0.3))
                            
                            VStack {
                                Text("Current Streak")
                                    .bold()
                                
                                Spacer(minLength: 10)
                                
                                Text ("INT days")
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pink.opacity(0.3))
                            
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
                            .fill(Color.pink.opacity(0.3))
                        
                        CustomCalendar()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                }
            }
            .navigationTitle("Activity")
            .background(Color.pink.opacity(0.5))
        }
    }
}

#Preview {
    UserActivity()
}
