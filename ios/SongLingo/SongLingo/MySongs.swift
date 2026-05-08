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
                            .fill(Constants.yellow)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("New🎵 (\(masteryLvlCounts[0]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.lavender)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Experimenting🤔 (\(masteryLvlCounts[1]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.blue)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Fan🧑‍🎤 (\(masteryLvlCounts[2]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.green)
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Your Jam🔥 (\(masteryLvlCounts[3]))")
                                .lineLimit(1)
                                .foregroundColor(.black)
                                .font(.system(size: 12))
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
            .background(Constants.sunset_horizon)
            .task {
                do {
                    let userID = UserDefaults.standard.string(forKey: "user_id") ?? "1"
                    let mySongsData = try await NetworkManager.shared.fetchMySongsData(userId: userID)
                    self.userSongs = mySongsData.userSongData
                    for songEntry in self.userSongs {
                        let totalActivities = (songEntry.numListens ?? 0) + (songEntry.numLyricChallengesCompleted ?? 0)
                        
                        masteryLvlCounts[calculateMasteryLvl(numActivitiesCompleted: totalActivities)] += 1
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
                        .fill(getMasteryLvlFillColor(entry))
                        .frame(width: 100, height: 25)
                        .shadow(
                            color: .black.opacity(0.3), radius: 4, x: 3, y: 3
                        )

                    // Map the Int mastery level back to text
                    Text("\(Constants.songsMasteryLvlToMessage[calculateMasteryLvl(numActivitiesCompleted: (entry.numListens ?? 0) + (entry.numLyricChallengesCompleted ?? 0))] ?? "Lvl")")
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
                
                Label("\(entry.numListens ?? 0) Listens", systemImage: "headphones.over.ear")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                
                Label("\(entry.numLyricChallengesCompleted ?? 0) Practices", systemImage: "square.and.pencil")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
}

private func getMasteryLvlFillColor(_ songEntry: UserSongEntry) -> LinearGradient {
    let totalActivities = (songEntry.numListens ?? 0) + (songEntry.numLyricChallengesCompleted ?? 0)
    let masteryLvl = calculateMasteryLvl(numActivitiesCompleted: totalActivities)
    let color: LinearGradient = Constants.masteryLvlToFillColor[masteryLvl] ?? Constants.green
    return color
    
}

#Preview {
    MySongs()
}
