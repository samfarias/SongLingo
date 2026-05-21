//
//  PlaylistCollection.swift
//  SongLingo
//
//  Created by Jaci on 5/7/26.
//

import SwiftUI

struct PlaylistCollection: View {

    @State private var playlistCollectionData: PlaylistCollectionData?
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    Spacer(minLength: 20)
                    
                    HStack {
                        Text("Your Playlists")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)

                        Spacer()

                        Button {
                            isGenerating = true
                            Task {
                                do {
                                    let _ = try await NetworkManager.shared.generateNewPlaylist()
                                    self.playlistCollectionData = try await NetworkManager.shared.fetchPlaylistCollectionData()
                                } catch {
                                    print("Error generating playlist: \(error)")
                                }
                                isGenerating = false
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if isGenerating {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "plus")
                                        .font(.caption.bold())
                                    Text("New Playlist")
                                        .font(.caption.bold())
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        }
                        .disabled(isGenerating)
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: 10)
                    
                    // --- Recently Played Section ---
                    renderSection(
                        title: "Recently Played",
                        playlists: playlistCollectionData?.playlistCollections.recentlyPlayed ?? []
                    )
                    
                    // --- New For You Section ---
                    renderSection(
                        title: "New For You",
                        playlists: playlistCollectionData?.playlistCollections.newPlaylists ?? []
                    )
                    
                    // --- A Trip Down Memory Lane Section ---
                    renderSection(
                        title: "A Trip Down Memory Lane",
                        playlists: playlistCollectionData?.playlistCollections.itsBeenAWhile ?? []
                    )
                }
            }
            .background (
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.030, green: 0.050, blue: 0.120),
                            Color(red: 0.275, green: 0.095, blue: 0.250),
                            Color(red: 0.110, green: 0.165, blue: 0.325)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(0..<150, id: \.self) { i in
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
                                Color.red.opacity(0.25),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: -100, y: 10)
                        
                        Spacer(minLength: 0.2)
                        
                        RadialGradient(
                            colors: [
                                Color.red.opacity(0.25),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: 200, y: -10)
                    }
                }
            )
            .task {
                do {
                    self.playlistCollectionData = try await NetworkManager.shared.fetchPlaylistCollectionData()
                } catch {
                    print("Unable to retrieve playlist collection: \(error)")
                }
            }
        }
    }
    
    // Helper to render each horizontal category
    @ViewBuilder
    private func renderSection(title: String, playlists: [Playlist]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            
            Divider()
                .background(Color.white.opacity(0.5))
                .padding(.horizontal)
            
            if playlists.isEmpty {
                Text("No playlists found")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(playlists) { playlist in
                            PlaylistCard(playlist: playlist)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// Subview for the individual playlist buttons
struct PlaylistCard: View {
    let playlist: Playlist
    
    var body: some View {
        NavigationLink(destination: SinglePlaylistView(playlistId: playlist.id)) {
            // Action to play playlist
            VStack(alignment: .leading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(getPlaylistBackground(playlist))
                        .frame(width: 140, height: 140)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                    
                    Image(systemName: "music.note.list")
                        .font(.system(size: 40))
                        .foregroundColor(getPlaylistForeground(playlist))
                }
                
                Text(playlist.playlistName)
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(playlist.proficiencyLevel)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 140)
            
        }
    }
}

// A helper function to fetch the right theme based on the playlist's data
func getPlaylistBackground(_ playlist: Playlist) -> LinearGradient {
    if playlist.playlistName.contains("Daily Mix") {
        return Constants.gold
    }
    return LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.600, green: 0.650, blue: 0.900),
            Color(red: 0.450, green: 0.500, blue: 0.800)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

func getPlaylistForeground(_ playlist: Playlist) -> Color {
    if playlist.playlistName.contains("Daily Mix") {
        return Color.black.opacity(0.8)
    }
    return Color.white.opacity(0.8)
}

#Preview {
    PlaylistCollection()
}
