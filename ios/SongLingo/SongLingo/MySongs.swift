//
//  MySongs.swift
//  SongLingo
//
//  Created by Jaci on 4/14/26.
//

import SwiftUI

struct MySongs: View {
    //Dummy info (again)
    @State private var songDemo = SongData(sName: "Einmal um die Welt", sArtist: "CRO", sEnjoyment: "Love", totalListeningTime: 88, totalLyricPractices: 47)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack (spacing: 5) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.yellow.opacity(0.5))
                        
                        HStack {
                            Text("New (INT)")
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
                            Text("Okay (INT)")
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
                            Text("Like (INT)")
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
                            Text("Love (INT)")
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
                
                HStack {
                    VStack (alignment: .leading) {
                        Text(songDemo.sName)
                            //.bold()
                            .font(.title2)
                            .foregroundColor(.black)
                            //.lineLimit(1)
                        
                        Text("(\(songDemo.sArtist))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    
                    VStack (alignment: .trailing) {
                        HStack {
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.green.opacity(0.6))
                                    .frame(height: 25)
                                    .frame(width: 100)

                                Text(songDemo.sEnjoyment)
                                    .lineLimit(1)
                                    .foregroundColor(.black)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        HStack {
                            Text("\(songDemo.totalListeningTime) Listens")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            
                            Image(systemName: "headphones.over.ear")
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                            
                            //Self-Note: Another image option is "headphones.sensor.tag.radiowaves.left.and.right" but it looks a little too much as a small icon
                        }
                        
                        HStack {
                            Text("\(songDemo.totalLyricPractices) Practices")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                        }

                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
            
                Divider()
                    .overlay(Color.black)
            }
            .navigationTitle("My Songs")
            .background(Color.pink.opacity(0.3))
            .task {
                do {
                    var mySongsData = try await fetchMySongsData(userId: "1")
                    // TESTING
//                    for songEntry in mySongsData.userSongData {
//                        print(songEntry.song.title)
//                        print(songEntry.song.artist)
//                        print(String(songEntry.numListens))
//                        print(String(songEntry.numLyricChallengesCompleted))
//                        print(String(songEntry.masteryLvl))
//                        print(" ")
//                        print("------")
//                        print(" ")
//                    }
                } catch {
                    print("Request failed: \(error)")
                }
            }
        }
    }
}

struct SongData {
    var sName: String
    var sArtist: String
    let sEnjoyment: String
    let totalListeningTime: Int
    let totalLyricPractices: Int
}

#Preview {
    MySongs()
}
