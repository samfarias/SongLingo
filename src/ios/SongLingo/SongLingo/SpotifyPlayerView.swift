import SwiftUI

struct SpotifyPlayerView: View {
    @State private var playlists: [Playlist] = []
    @State private var expandedPlaylistId: Int? = nil
    @State private var playlistSongs: [Int: [PlaylistSongEntry]] = [:]
    @State private var isLoading = true
    @State private var nowPlayingTitle: String? = nil
    
    @AppStorage("spotifyLinked") private var spotifyLinked = false
    @State private var isLinkingSpotify = false

    var body: some View {
        NavigationStack {
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
                            Color.gray.opacity(0.15),
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
                            Color.gray.opacity(0.2),
                                .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: 200, y: -10)
                }

                if isLoading {
                    ProgressView("Loading playlists...")
                        .foregroundColor(.white)
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                } else if playlists.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No playlists yet")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text("Generate playlists from the Home tab to see them here")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            if !spotifyLinked {
                                Button {
                                    isLinkingSpotify = true
                                    Task {
                                        do {
                                            try await SpotifyAuthManager.shared.connect()
                                            let _ = try await NetworkManager.shared.generateNewPlaylist()
                                            await loadPlaylists()
                                        } catch {
                                            print("Spotify link error: \(error)")
                                        }
                                        isLinkingSpotify = false
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "link.circle.fill")
                                            .foregroundColor(.green)
                                        
                                        Text("Link Spotify for full playback")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                        
                                        if isLinkingSpotify {
                                            ProgressView().tint(.green)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(12)
                                }
                                .disabled(isLinkingSpotify)
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }

                            ForEach(playlists) { playlist in
                                VStack(spacing: 0) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            if expandedPlaylistId == playlist.id {
                                                expandedPlaylistId = nil
                                            } else {
                                                expandedPlaylistId = playlist.id
                                                if playlistSongs[playlist.id] == nil {
                                                    Task { await loadSongs(for: playlist.id) }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 14) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.green.opacity(0.6), .green.opacity(0.3)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 50, height: 50)

                                                Image(systemName: "music.note.list")
                                                    .foregroundColor(.white)
                                                    .font(.title3)
                                            }

                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(playlist.playlistName)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)

                                                Text("\(Constants.languageIdToName[playlist.language] ?? "Language") · \(playlist.proficiencyLevel)")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            Image(systemName: expandedPlaylistId == playlist.id ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                    }

                                    if expandedPlaylistId == playlist.id {
                                        if let songs = playlistSongs[playlist.id] {
                                            VStack(spacing: 0) {
                                                ForEach(songs) { song in
                                                    Button {
                                                        nowPlayingTitle = song.song.title
                                                        openInSpotify(title: song.song.title, artist: song.song.artist, spotifyId: song.song.spotifyId)
                                                        if let pid = expandedPlaylistId {
                                                            Task {
                                                                try? await NetworkManager.shared.updateUserSongProgress(song_id: song.song.id, request_type: "song_listen", playlist_id: pid)
                                                            }
                                                        }
                                                    } label: {
                                                        HStack(spacing: 12) {
                                                            Image(systemName: nowPlayingTitle == song.song.title ? "speaker.wave.2.fill" : "play.fill")
                                                                .foregroundColor(nowPlayingTitle == song.song.title ? .green : .white.opacity(0.6))
                                                                .font(.caption)
                                                                .frame(width: 20)

                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text(song.song.title)
                                                                    .font(.subheadline)
                                                                    .foregroundColor(nowPlayingTitle == song.song.title ? .green : .white)
                                                                    .lineLimit(1)

                                                                Text(song.song.artist)
                                                                    .font(.caption2)
                                                                    .foregroundColor(.gray)
                                                                    .lineLimit(1)
                                                            }

                                                            Spacer()

                                                            Text(Constants.genreIdToName[song.song.genre] ?? "")
                                                                .font(.caption2)
                                                                .foregroundColor(.gray.opacity(0.7))
                                                        }
                                                        .padding(.horizontal, 28)
                                                        .padding(.vertical, 8)
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 8)
                                            .transition(.opacity)
                                        } else {
                                            HStack {
                                                Spacer()
                                                ProgressView().tint(.green)
                                                Spacer()
                                            }
                                            .padding(.vertical, 12)
                                        }
                                    }

                                    Divider().background(Color.white.opacity(0.08))
                                }
                            }
                        }
                        .padding(.top, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Player")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.vertical)
                }
            }
            .task {
                await loadPlaylists()
            }
        }
    }

    func loadPlaylists() async {
        do {
            let data = try await NetworkManager.shared.fetchPlaylistCollectionData()
            let collections = data.playlistCollections
            self.playlists = collections.recentlyPlayed + collections.newPlaylists + collections.itsBeenAWhile
            self.isLoading = false
        } catch {
            print("Failed to load playlists: \(error)")
            self.isLoading = false
        }
    }

    func loadSongs(for playlistId: Int) async {
        do {
            let data = try await NetworkManager.shared.fetchSinglePlaylistData(playlistId: playlistId)
            await MainActor.run {
                self.playlistSongs[playlistId] = data.playlistSongs
            }
        } catch {
            print("Failed to load songs for playlist \(playlistId): \(error)")
        }
    }
}

#Preview {
    SpotifyPlayerView()
}
