//
//  Dashboard.swift
//  SongLingo
//
//  Created by Jaci on 3/23/26.
//

import SwiftUI

struct Dashboard: View {
    @State private var homeData: HomeScreenData?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack (alignment: .top) {
                    VStack {
                        Spacer()
                        
                        Text("Welcome Back, \(homeData?.userInfo.firstName ?? "User")!")
                            .font(.title.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        Text("You're learning \(Constants.languageIdToName[homeData?.userInfo.targetLanguage ?? 0] ?? "Language name") · \(homeData?.userInfo.proficiencyLevel ?? "Proficiency Level")")
                            .font(.footnote.weight(.light))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)

                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.2), // Top overlay color
                                Color.clear               // Fades into the background
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                }
                
                //Handles the space between the the subtitle and Word Bank, My Songs, and Streak buttons
                Spacer(minLength: 30)
                
                //Handles the Word Bank, My Songs, and Streak buttons
                HStack (spacing: 10) {
                    
                    NavigationLink(destination: WordBank()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.blue)
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
                                    
                                    Text ("(\(homeData?.userProgress.numWordsLearned ?? -1))")
                                        .foregroundColor(.black)
                                        .font(.system(size: 8))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                        }
                        .shadow(
                            color: .black.opacity(0.15), // Subtle transparency
                            radius: 4,                   // Small blur for a clean edge
                            x: 5,                        // Shifts shadow to the right
                            y: 5                         // Shifts shadow downwards
                        )
                        .frame(maxWidth: .infinity)
                    }
                    
                    
                    NavigationLink(destination: MySongs()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.lavender)
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
                                    
                                    Text ("(\(homeData?.userProgress.numSongsCompleted ?? -1))")
                                        .foregroundColor(.black)
                                        .font(.system(size: 8))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                        }
                        .shadow(
                            color: .black.opacity(0.15), // Subtle transparency
                            radius: 4,                   // Small blur for a clean edge
                            x: 5,                        // Shifts shadow to the right
                            y: 5                         // Shifts shadow downwards
                        )
                        .frame(maxWidth: .infinity)
                    }
                    
                    NavigationLink(destination: UserActivity())
                    {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.sunburst)
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
                                    
                                    Text ("\(homeData?.userProgress.currentStreak ?? -1) days!")
                                        .foregroundColor(.black)
                                        .font(.system(size: 8))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                        }
                        .shadow(
                            color: .black.opacity(0.15), // Subtle transparency
                            radius: 4,                   // Small blur for a clean edge
                            x: 5,                        // Shifts shadow to the right
                            y: 5                         // Shifts shadow downwards
                        )
                        .frame(maxWidth: .infinity)
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    // MARK: - Current Playlists Section
                    VStack(alignment: .leading, spacing: 15) {
                        // 1. Section Header
                        Text("Current Playlists")
                            .font(.headline)
                            .padding(.leading, 15)
                            .padding(.top, 15)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(homeData?.suggestedPlaylists.recentlyPlayed ?? [], id: \.playlistName) { playlist in
                                    Button(action: {
                                        print("Selected: \(playlist.playlistName)")
                                    }) {
                                        ZStack {
                                            // Card Background using your Morning Sage gradient
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Constants.mint)
                                            
                                            VStack(spacing: 8) {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.2))
                                                
//                                                Spacer()
                                                
                                                Text(playlist.playlistName)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                                
                                                Spacer()
                                                
                                                Text("\(Constants.languageIdToName[playlist.language] ?? "ID") · \(playlist.proficiencyLevel)")
                                                    .font(.system(size: 9))
                                                
                                                Text("\(Constants.genreIdToName[playlist.genre] ?? "ID")")
                                                    .font(.system(size: 9))
                                            }
                                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.2))
                                            .padding(12)
                                        }
                                        .frame(width: 110, height: 150)
                                        // Card Shadow (Bottom-Right)
                                        .shadow(color: Color(red: 0.4, green: 0.6, blue: 0.5).opacity(0.3), radius: 5, x: 3, y: 3)
                                    }
                                }
                            }
                            .padding(.horizontal, 15) // Keeps cards from touching the container edges
                            .padding(.bottom, 30)     // Extra room for the card shadows
                            .padding(.top, 5)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.05), lineWidth: 3) // Keeps the crisp edge
                    )
                    
//                    Spacer(minLength: 20)
                    
                    // -- MARK: Handles This Week's Word Cards Section
                    VStack (alignment: .leading) {
                        //Handles the This Week's Word Cards headline
                        Text("This Week's Word Cards")
                            .font(.headline)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.red)
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
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.5), // Top overlay color
                                            Color.clear           // Fades into the background
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black.opacity(0.30), lineWidth: 2) // Keeps the crisp edge
                                )
                                .cornerRadius(5)
                                
                            }
                            .padding()
                        }
                        .shadow(
                            color: .black.opacity(0.15), // Subtle transparency
                            radius: 4,                   // Small blur for a clean edge
                            x: 5,                        // Shifts shadow to the right
                            y: 5                         // Shifts shadow downwards
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
                                .fill(Constants.red)
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
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.5), // Top overlay color
                                            Color.clear              // Fades into the background
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.black.opacity(0.20), lineWidth: 2) // Keeps the crisp edge
                                )
                                .cornerRadius(5)
                                
                            }
                            .padding()
                        }
                        .shadow(
                            color: .black.opacity(0.15), // Subtle transparency
                            radius: 4,                   // Small blur for a clean edge
                            x: 5,                        // Shifts shadow to the right
                            y: 5                         // Shifts shadow downwards
                        )
                        
                    }
                    .padding(.vertical)
                }
                .padding()
                
            }
            .background(Constants.arctic_dawn)
            .edgesIgnoringSafeArea(.all)
            //This works equally as well: .ignoresSafeArea()
            //.scrollBounceBehavior(.basedOnSize)
            //.ignoresSafeArea(edges: .top)
            .task {
                do {
                    self.homeData = try await fetchHomeScreenData(userId: "1")

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
