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
                            .fill(Constants.yellow.opacity(0.8))
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("New 🎵\n\(masteryLvlCounts[0])")
                                .foregroundColor(.black.opacity(0.95))
                                .font(.system(size: 9))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.lavender.opacity(0.8))
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Exploring 🤔\n\(masteryLvlCounts[1])")
                                .foregroundColor(.black.opacity(0.95))
                                .font(.system(size: 8.5))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.blue.opacity(0.8))
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Fan 🧑‍🎤\n\(masteryLvlCounts[2])")
                                .foregroundColor(.black.opacity(0.95))
                                .font(.system(size: 9))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Constants.green.opacity(0.8))
                            .shadow(
                                color: .black.opacity(0.25), radius: 3, x: 1, y: 1
                            )
                        
                        HStack {
                            Text("Your Jam 🔥\n\(masteryLvlCounts[3])")
                                .foregroundColor(.black.opacity(0.95))
                                .font(.system(size: 9))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                Divider()
                    .overlay(Color.white.opacity(0.9))
                
                ForEach(userSongs) { entry in
                    SongRow(entry: entry)
                    Divider()
                        .overlay(Color.white)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Songs")
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
                    let mySongsData = try await NetworkManager.shared.fetchMySongsData()
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
    @AppStorage("nowPlayingTitle") private var nowPlayingTitle: String = ""
    @AppStorage("nowPlayingArtist") private var nowPlayingArtist: String = ""
    @AppStorage("nowPlayingArt") private var nowPlayingArt: String = ""

    var body: some View {
        HStack {
            Button {
                nowPlayingTitle = entry.song.title
                nowPlayingArtist = entry.song.artist
                nowPlayingArt = entry.song.albumArtUrl ?? ""
                openInSpotify(title: entry.song.title, artist: entry.song.artist, spotifyId: entry.song.spotifyId)
                Task {
                    try? await NetworkManager.shared.updateUserSongProgress(song_id: entry.song.id, request_type: "song_listen", playlist_id: -1)
                }
            } label: {
                ZStack {
                    if let artUrl = entry.song.albumArtUrl, let url = URL(string: artUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.1))
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.1))
                            .frame(width: 48, height: 48)
                    }
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                }
            }
            .padding(.leading)

            VStack(alignment: .leading) {
                Text(entry.song.title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.95))

                Text(entry.song.artist)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 8)

            Spacer()
            
            VStack(alignment: .trailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(getMasteryLvlFillColor(entry))
                        .frame(width: 100, height: 25)
                        .shadow(
                            color: .black.opacity(0.3), radius: 4, x: 3, y: 3
                        )

                    Text("\(Constants.songsMasteryLvlToMessage[calculateMasteryLvl(numActivitiesCompleted: (entry.numListens ?? 0) + (entry.numLyricChallengesCompleted ?? 0))] ?? "Lvl")")
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
                
                Label("\(entry.numListens ?? 0) Listens", systemImage: "headphones.over.ear")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.95))
                
                Label("\(entry.numLyricChallengesCompleted ?? 0) Practices", systemImage: "square.and.pencil")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.95))
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
