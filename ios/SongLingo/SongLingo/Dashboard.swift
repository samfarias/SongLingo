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
            ScrollView {
                ZStack (alignment: .top) {
                    VStack {
                        Spacer()
                        
                        Text("Welcome Back _!")
                            .font(.title.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        Text("You're learning language_name · proficiency")
                            .font(.footnote.weight(.light))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)

                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .background(Color.purple)
                }
                
                //Handles the space between the the subtitle and Word Bank, My Songs, and Streak buttons
                Spacer(minLength: 30)
                
                //Handles the Word Bank, My Songs, and Streak buttons
                HStack (spacing: 10) {
                    
                    NavigationLink(destination: WordBank()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.7))
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
                    
                    
                    NavigationLink(destination: MySongs()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.7))
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
                    
                    NavigationLink(destination: UserActivity())
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.7))
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
                
                Spacer(minLength: 20)
                
                //Handles the Current Playlists Section
                VStack (alignment: .leading) {
                    //Handles the Current Playlists headline
                    Text("Current Playlists")
                        .font(.headline)
                    
                    //Handles the current playlist buttons
                    ScrollView (.horizontal) {
                        HStack (spacing: 6) {
                            Button(action: {
                                // Action for specific Playlist button
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.9))
                                    HStack {
                                        VStack (alignment: .center) {
                                            Image(systemName: "play.circle")
                                                .foregroundColor(.black)
                                                .font(.system(size: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 1)
                                                        .frame(width: 100, height: 60)
                                                    )
                                                .padding(.bottom, 20)
                    
                                            Text("Playlist # _ ")
                                                .bold()
                                                .lineLimit(1)
                                                .font(.system(size: 14))
                                                .padding(.bottom, 2)
                                            
                                            Text("Language · Genre · _ Songs")
                                                .font(.system(size: 8))
                                                .lineLimit(1)
                                        }
                                        .foregroundColor(.black)
                                        //.padding(.horizontal)
                                        .padding(.vertical, 16)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                        .frame(width: 120, height: 150)
                                        .padding(.vertical, 20)
                                    )
                            }
                            .frame(width: 121, height: 151)
                            
                            //Self-Note: The horizontal ScrollView cuts off the border on the sides. This is the overall layout of the Playlist button.
                            //FIXED
                            
                            Button(action: {
                                // Action for specific Playlist button
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.9))
                                    HStack {
                                        VStack (alignment: .center) {
                                            Image(systemName: "play.circle")
                                                .foregroundColor(.black)
                                                .font(.system(size: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 1)
                                                        .frame(width: 100, height: 60)
                                                    )
                                                .padding(.bottom, 20)
                    
                                            Text("Playlist # _ ")
                                                .bold()
                                                .lineLimit(1)
                                                .font(.system(size: 14))
                                                .padding(.bottom, 2)
                                            
                                            Text("Language · Genre · _ Songs")
                                                .font(.system(size: 8))
                                                .lineLimit(1)
                                        }
                                        .foregroundColor(.black)
                                        //.padding(.horizontal)
                                        .padding(.vertical, 16)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                        .frame(width: 120, height: 150)
                                        .padding(.vertical, 20)
                                    )
                            }
                            .frame(width: 121, height: 151)
                            
                            
                            Button(action: {
                                // Action for specific Playlist button
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.9))
                                    HStack {
                                        VStack (alignment: .center) {
                                            Image(systemName: "play.circle")
                                                .foregroundColor(.black)
                                                .font(.system(size: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 1)
                                                        .frame(width: 100, height: 60)
                                                    )
                                                .padding(.bottom, 20)
                    
                                            Text("Playlist # _ ")
                                                .bold()
                                                .lineLimit(1)
                                                .font(.system(size: 14))
                                                .padding(.bottom, 2)
                                            
                                            Text("Language · Genre · _ Songs")
                                                .font(.system(size: 8))
                                                .lineLimit(1)
                                        }
                                        .foregroundColor(.black)
                                        //.padding(.horizontal)
                                        .padding(.vertical, 16)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                        .frame(width: 120, height: 150)
                                        .padding(.vertical, 20)
                                    )
                            }
                            .frame(width: 121, height: 151)
                            
                            Button(action: {
                                // Action for specific Playlist button
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.green.opacity(0.9))
                                    HStack {
                                        VStack (alignment: .center) {
                                            Image(systemName: "play.circle")
                                                .foregroundColor(.black)
                                                .font(.system(size: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.black, lineWidth: 1)
                                                        .frame(width: 100, height: 60)
                                                    )
                                                .padding(.bottom, 20)
                    
                                            Text("Playlist # _ ")
                                                .bold()
                                                .lineLimit(1)
                                                .font(.system(size: 14))
                                                .padding(.bottom, 2)
                                            
                                            Text("Language · Genre · _ Songs")
                                                .font(.system(size: 8))
                                                .lineLimit(1)
                                        }
                                        .foregroundColor(.black)
                                        //.padding(.horizontal)
                                        .padding(.vertical, 16)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                        .frame(width: 120, height: 150)
                                        .padding(.vertical, 20)
                                    )
                            }
                            .frame(width: 121, height: 151)
                            
                        }
                    }
                    //.background(Color.red)
                    //.padding(.vertical)
                    //.frame(width: 150, height: 150)
                    
                    Spacer(minLength: 20)
                    
                    //Handles This Week's Word Cards Section
                    VStack (alignment: .leading) {
                        //Handles the This Week's Word Cards headline
                        Text("This Week's Word Cards")
                            .font(.headline)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.5))
                            HStack {
                                VStack (alignment: .leading) {
                                    Text("_ new words waiting for you!")
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 14))
                                    
                                    Spacer(minLength: 1)
                                    
                                    Text("Complete your daily practice to maintain your streak")
                                        .foregroundStyle(.black)
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
                                .background(Color(.indigo.opacity(0.7)))
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
                                .fill(Color.purple.opacity(0.5))
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
                                
                                NavigationLink(destination: PracticeGameOptions()) {
                                    Text("Practice")
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 12))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                    
                                }
                                .background(Color(.indigo.opacity(0.7)))
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
            .background(Color.purple.opacity(0.2))
            .edgesIgnoringSafeArea(.all)
            //This works equally as well: .ignoresSafeArea()
            //.scrollBounceBehavior(.basedOnSize)
            //.ignoresSafeArea(edges: .top)
            .task {
                do {
                    let homeScreenData = try await fetchHomeScreenData(userId: "1")
                    // TESTING
//                    print("Name: " + homeScreenData.userInfo.firstName + " " + homeScreenData.userInfo.lastName)
//                    print("Target language: \(homeScreenData.userInfo.targetLanguage)")
//                    print("Proficiency level: \(homeScreenData.userInfo.proficiencyLevel)")
//                    print("numWordsLearned: \(homeScreenData.userProgress.numWordsLearned)")
//                    print("numSongsCompleted: \(homeScreenData.userProgress.numSongsCompleted)")
//                    print("currentStreak: \(homeScreenData.userProgress.currentStreak)")
//                    print("Recent playlists:")
//                    for playlist in homeScreenData.suggestedPlaylists.recentlyPlayed {
//                        print(playlist.playlistName)
//                    }

                } catch {
                    print("Request failed: \(error)")
                }
            }
        }

    }
}

#Preview {
    Dashboard()
}


//NOTE - SCROLLVIEW IS NOW ALLOWING ME TO BYPASS THE SAFE AREA
