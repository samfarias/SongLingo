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
                    // Hero album art
                    if let url = heroArtUrl {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 260)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.7)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        } placeholder: {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(height: 260)
                        }
                    }

                    // Playlist info header
                    if let info = singlePlaylistData?.playlistInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(info.description)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal)
                        }
                        .padding(.top, 16)
                    }

                    // Song list
                    if let songs = singlePlaylistData?.playlistSongs {
                        LazyVStack(spacing: 0) {
                            ForEach(songs) { entry in
                                PlaylistSongRow(entry: entry)
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
            .navigationTitle(singlePlaylistData?.playlistInfo.playlistName ?? "Playlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .background {
                ZStack {
                    Color(red: 0.06, green: 0.06, blue: 0.12)
                        .ignoresSafeArea()

                    // Blurred album art background
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
                        .ignoresSafeArea()
                    }
                }
            }
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

    var body: some View {
        HStack(spacing: 12) {
            // Album art thumbnail
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

#Preview {
    SinglePlaylistView(playlistId: -1)
}
