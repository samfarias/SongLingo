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

    private var heroArtUrl: URL? {
        guard let songs = singlePlaylistData?.playlistSongs,
              let first = songs.first(where: { $0.song.albumArtUrl != nil }) else { return nil }
        return URL(string: first.song.albumArtUrl!)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if let url = heroArtUrl {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 260)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(height: 260)
                        }
                    }

                    if let info = singlePlaylistData?.playlistInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(info.description)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal)
                        }
                        .padding(.top, 16)
                    }

                    if let songs = singlePlaylistData?.playlistSongs {
                        LazyVStack(spacing: 0) {
                            ForEach(songs) { entry in
                                PlaylistSongRow(entry: entry, playlistId: playlistId)
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                            }
                        }
                        .padding(.top, 12)
                    } else {
                        ProgressView("Loading Playlist...")
                            .tint(.white)
                            .foregroundStyle(.white)
                            .padding(.top, 60)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(singlePlaylistData?.playlistInfo.playlistName ?? "Playlist")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.vertical)
                }
            }
            .background (
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.07, green: 0.07, blue: 0.07),
                            Color(red: 0.12, green: 0.12, blue: 0.14),
                            Color(red: 0.07, green: 0.07, blue: 0.07)
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
                                Color.gray.opacity(0.15),
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
                                Color.gray.opacity(0.15),
                                    .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 200
                        )
                        .frame(width: 400, height: 400)
                        .offset(x: 95, y: -10)
                    }

                    if let url = heroArtUrl {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .blur(radius: 80)
                                .saturation(1.4)
                                .opacity(0.5)
                        } placeholder: {
                            EmptyView()
                        }
                    }
                }
            )
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

struct PlaylistSongRow: View {
    let entry: PlaylistSongEntry
    let playlistId: Int

    var body: some View {
        HStack(spacing: 12) {
            if let artUrl = entry.song.albumArtUrl, let url = URL(string: artUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white.opacity(0.1))
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.1))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundStyle(.white.opacity(0.4))
                    )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.song.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(entry.song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()

            Button {
                openInSpotify(title: entry.song.title, artist: entry.song.artist, spotifyId: entry.song.spotifyId)
                Task {
                    try? await NetworkManager.shared.updateUserSongProgress(song_id: entry.song.id, request_type: "song_listen", playlist_id: playlistId)
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

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

#Preview {
    SinglePlaylistView(playlistId: -1)
}
