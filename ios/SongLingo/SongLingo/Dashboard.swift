//
//  Dashboard.swift
//  SongLingo
//
//  Created by Jaci on 3/23/26.
//

import SwiftUI

struct Dashboard: View {
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.purple
                    .frame(height: 200)
                    .ignoresSafeArea(edges: .top)
                
                Color(.purple).opacity(0.2)
                    .edgesIgnoringSafeArea([.bottom, .horizontal])
                
                ScrollView {
                    //Handles the subtitle message
                    VStack (spacing: 20) {
                        Text("You're learning language_name · proficiency")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 1)
                    
                    //Handles the space between the the subtitle and Word Bank, My Songs, and Streak buttons
                    Spacer(minLength: 40)
                    
                    //Handles the Word Bank, My Songs, and Streak buttons
                    HStack (spacing: 10) {
                        Button(action: {
                                // Action for Word Bank Button
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue)
                                    HStack {
                                        Image(systemName: "book")
                                            .padding(4)
                                            .foregroundColor(.black)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color.black, lineWidth: 1)
                                                )
                                            .font(.system(size: 12))
                                        VStack (alignment: .leading) {
                                            Text("Word Bank")
                                                .foregroundColor(.black)
                                                .font(.system(size: 10))
                                                .lineLimit(1)
                                            Text ("INT")
                                                .foregroundColor(.black)
                                                .font(.system(size: 8))
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.horizontal)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                    )
                                .frame(maxWidth: .infinity)
                            }
                        
                        
                        Button(action: {
                            // Action for My Songs button
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.purple)
                                HStack {
                                    //Self-note: Another possibility for the image can be the "opticaldisc"
                                    Image(systemName: "music.note.square.stack")
                                        .padding(4)
                                        .foregroundColor(.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.black, lineWidth: 1)
                                            )
                                        .font(.system(size: 12))
                                    VStack (alignment: .leading) {
                                        Text("My Songs")
                                            .foregroundColor(.black)
                                            .font(.system(size: 10))
                                            .lineLimit(1)
                                        Text ("INT")
                                            .foregroundColor(.black)
                                            .font(.system(size: 8))
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                )
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            // Action for Streak button
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.pink)
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .padding(4)
                                        .foregroundColor(.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.black, lineWidth: 1)
                                            )
                                        .font(.system(size: 12))
                                    VStack (alignment: .leading) {
                                        Text("Streak")
                                            .foregroundColor(.black)
                                            .font(.system(size: 10))
                                            .lineLimit(1)
                                        Text ("INT")
                                            .foregroundColor(.black)
                                            .font(.system(size: 8))
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 15)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                )
                            .frame(maxWidth: .infinity)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    //Handles the Current Playlists Section
                    VStack (alignment: .leading) {
                        //Handles the Current Playlists headline
                        Text("Current Playlists")
                            .font(.headline)
                        
                        //Handles the current playlist buttons
                        ScrollView (.horizontal) {
                            HStack (spacing: 10) {
                                Button(action: {
                                    // Action for specific Playlist button
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.green)
                                        HStack {
                                            VStack {
                                                Text("IMAGE")
                                                Text("TITLE ")
                                                Text("Language · Genre · _ Songs")
                                            }
                                            .foregroundColor(.black)
                                            //.padding(.horizontal)
                                            .padding(.vertical, 10)
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 1)
                                            .frame(width: 120, height: 150)
                                        )
                                }
                                .frame(width: 120, height: 150)
                                
                                //Self-Note: The horizontal ScrollView cuts off the border on the sides. This is the overall layout of the Playlist button.
                            }
                        }
                        
                        //Handles This Week's Word Cards Section
                        VStack (alignment: .leading) {
                            //Handles the This Week's Word Cards headline
                            Text("This Week's Word Cards")
                                .font(.headline)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.brown)
                                HStack {
                                    VStack (alignment: .leading) {
                                        Text("_ new words waiting for you!")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 14))
                                        
                                        Spacer(minLength: 1)
                                        
                                        Text("Complete your daily practice to maintain your streak")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 10, weight: .thin, design: .rounded))
                                    }
                                    .padding(.horizontal, 10)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // Action for New Words button
                                    }) {
                                        Text("Begin")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 12))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 12)
                                        
                                    }
                                    .background(Color(.indigo))
                                    .cornerRadius(5)
                                    
                                }
                                .padding()
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                )
                            
                        }
                        .padding(.vertical)
                        
                        //Handles This Week's Word Cards Section
                        VStack (alignment: .leading) {
                            //Handles the Practice Games headline
                            Text("Practice Games")
                                .font(.headline)
                
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.cyan)
                                HStack {
                                    VStack (alignment: .leading) {
                                        Text("Ready to test your vocabulary?")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 14))
                                        
                                        Spacer(minLength: 1)
                                        
                                        Text("Take a quiz on words from your completed songs")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 10, weight: .thin, design: .rounded))
                                    }
                                    .padding(.horizontal, 10)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // Action for Practice button
                                    }) {
                                        Text("Begin")
                                            .foregroundStyle(Color.black)
                                            .font(.system(size: 12))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 12)
                                        
                                    }
                                    .background(Color(.indigo))
                                    .cornerRadius(5)
                                    
                                }
                                .padding()
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                                )
                            
                        }
                        .padding(.vertical)
                    }
                    .padding()
                    
                }
                .navigationTitle("Welcome Back!")
            }
        }
    }
}

#Preview {
    Dashboard()
}
