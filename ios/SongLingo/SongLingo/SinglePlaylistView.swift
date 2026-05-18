//
//  SinglePlaylistView.swift
//  SongLingo
//
//  Created by Austin Robertson on 5/12/26.
//

import SwiftUI

struct SinglePlaylistView: View {
    
    let playlistId: Int
    @State private var singlePlaylistData: SinglePlaylistData?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Header Stats Section
                if let info = singlePlaylistData?.playlistInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(info.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.top, 5)
                }
                
                Divider()
                    .overlay(Color.black)
                    .padding(.top)
                
                // Dynamic List of Songs from the playlist
                if let songs = singlePlaylistData?.playlistSongs {
                    ForEach(songs) { entry in
                        PlaylistSongRow(entry: entry)
                        Divider().overlay(Color.black)
                    }
                } else {
                    ProgressView("Loading Playlist...")
                        .padding()
                }
            }
            .navigationTitle("🎵 \(singlePlaylistData?.playlistInfo.playlistName ?? "Playlist") 🎵")
            .background(Constants.sunset_horizon)
            .task {
                do {
                    self.singlePlaylistData = try await NetworkManager.shared.fetchSinglePlaylistData(playlistId: self.playlistId)
                } catch {
                    print("Request failed: \(error)")
                }
            }
        }
    }
}

// Reusable Badge for the Header
struct StatBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(color)
                .shadow(color: .black.opacity(0.25), radius: 3, x: 1, y: 1)
            
            Text(text)
                .lineLimit(1)
                .foregroundColor(.black)
                .font(.system(size: 10, weight: .medium))
                .padding(.horizontal, 4)
        }
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}

struct PlaylistSongRow: View {
    let entry: PlaylistSongEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.song.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(entry.song.artist)
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(width: 80, height: 22)
                    
                    Text("\(Constants.genreIdToName[entry.song.genre] ?? "Genre") · \(entry.song.proficiencyLevel)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    SinglePlaylistView(playlistId: -1)
}
