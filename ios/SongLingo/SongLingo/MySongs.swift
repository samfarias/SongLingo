//
//  MySongs.swift
//  SongLingo
//
//  Created by Jaci on 4/14/26.
//

import SwiftUI

struct MySongs: View {
    @State private var userSongs: [UserSongEntry] = []
    @State private var masteryLvlCounts = [0, 0, 0, 0]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack (spacing: 5) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.yellow.opacity(0.5))
                        
                        HStack {
                            Text("New🎵 (\(masteryLvlCounts[0]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple.opacity(0.4))
                        
                        HStack {
                            Text("Experimenting🤔 (\(masteryLvlCounts[1]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.4))
                        
                        HStack {
                            Text("Fan🧑‍🎤 (\(masteryLvlCounts[2]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.6))
                        
                        HStack {
                            Text("Your Jam🔥 (\(masteryLvlCounts[3]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 8.5))
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                Divider()
                    .overlay(Color.black)
                
                // Dynamic List of Songs
                ForEach(userSongs) { entry in
                    SongRow(entry: entry)
                    Divider().overlay(Color.black)
                }
            }
            .navigationTitle("My Songs")
            .background(Color.pink.opacity(0.3))
            .task {
                do {
                    let mySongsData = try await fetchMySongsData(userId: "1")
                    self.userSongs = mySongsData.userSongData
                    for songEntry in self.userSongs {
                        masteryLvlCounts[ calculateMasteryLvl(numActivitiesCompleted: songEntry.numListens + songEntry.numLyricChallengesCompleted)
                        ] += 1
                    }
                } catch {
                    print("Request failed: \(error)")
                }
            }
        }
    }
}

struct SongRow: View {
    let entry: UserSongEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.song.title)
                    .font(.title2)
                    .foregroundColor(.black)
                
                Text("(\(entry.song.artist))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                // Mastery Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Constants.masteryLvlToFillColor[calculateMasteryLvl(numActivitiesCompleted: entry.numListens + entry.numLyricChallengesCompleted)] ?? Color.green.opacity(0.6))
                        .frame(width: 100, height: 25)

                    // Map the Int mastery level back to text
                    Text("\(Constants.masteryLvlToMessage[calculateMasteryLvl(numActivitiesCompleted: entry.numListens + entry.numLyricChallengesCompleted)] ?? "Lvl")")
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
                
                Label("\(entry.numListens) Listens", systemImage: "headphones.over.ear")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                
                Label("\(entry.numLyricChallengesCompleted) Practices", systemImage: "square.and.pencil")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    MySongs()
}
