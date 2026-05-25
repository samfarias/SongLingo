import SwiftUI

struct SpotifyPlayerView: View {
    @State private var playlists: [Playlist] = []
    @State private var playlistSongs: [Int: [PlaylistSongEntry]] = [:]
    @State private var isLoading = true
    @State private var nowPlayingTitle: String? = nil
    @State private var nowPlayingArtist: String? = nil
    @State private var nowPlayingArt: String? = nil
    @State private var nowPlayingPlaylistId: Int? = nil

    @AppStorage("spotifyLinked") private var spotifyLinked = false
    @State private var isLinkingSpotify = false

    private let durations = ["3:24", "2:58", "3:47", "4:12", "3:05", "3:33", "2:41", "3:19", "4:01", "3:15"]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.06, blue: 0.08),
                        Color(red: 0.10, green: 0.08, blue: 0.14),
                        Color(red: 0.06, green: 0.06, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

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
                            nowPlayingCard
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .padding(.bottom, 24)

                            if !spotifyLinked {
                                spotifyLinkBanner
                                    .padding(.horizontal)
                                    .padding(.bottom, 16)
                            }

                            ForEach(playlists) { playlist in
                                playlistSection(playlist)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Player")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .task {
                await loadAllData()
            }
        }
    }

    // MARK: - Now Playing Card

    private var nowPlayingCard: some View {
        VStack(spacing: 16) {
            if let artUrl = nowPlayingArt, let url = URL(string: artUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    albumArtPlaceholder
                }
                .frame(width: 220, height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .green.opacity(0.2), radius: 20, x: 0, y: 10)
            } else {
                albumArtPlaceholder
                    .frame(width: 220, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(spacing: 4) {
                Text(nowPlayingTitle ?? "Not Playing")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(nowPlayingArtist ?? "Select a song below")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 4)

                        Capsule()
                            .fill(Color.green)
                            .frame(width: nowPlayingTitle != nil ? geo.size.width * 0.35 : 0, height: 4)

                        if nowPlayingTitle != nil {
                            Circle()
                                .fill(.white)
                                .frame(width: 12, height: 12)
                                .offset(x: geo.size.width * 0.35 - 6)
                        }
                    }
                }
                .frame(height: 12)

                HStack {
                    Text(nowPlayingTitle != nil ? "1:14" : "0:00")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(nowPlayingTitle != nil ? "3:32" : "0:00")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 4)

            HStack(spacing: 36) {
                Image(systemName: "shuffle")
                    .font(.body)
                    .foregroundColor(.green.opacity(0.8))

                Image(systemName: "backward.fill")
                    .font(.title3)
                    .foregroundColor(.white)

                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 52, height: 52)

                    Image(systemName: nowPlayingTitle != nil ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.black)
                        .offset(x: nowPlayingTitle != nil ? 0 : 2)
                }

                Image(systemName: "forward.fill")
                    .font(.title3)
                    .foregroundColor(.white)

                Image(systemName: "repeat")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var albumArtPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "music.note")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.white.opacity(0.4))
        }
    }

    // MARK: - Spotify Link Banner

    private var spotifyLinkBanner: some View {
        Button {
            isLinkingSpotify = true
            Task {
                do {
                    try await SpotifyAuthManager.shared.connect()
                    let _ = try await NetworkManager.shared.generateNewPlaylist()
                    await loadAllData()
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
    }

    // MARK: - Playlist Section

    @ViewBuilder
    private func playlistSection(_ playlist: Playlist) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.green)
                    .frame(width: 3, height: 18)

                Text(playlist.playlistName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                let langName = Constants.languageIdToName[playlist.language] ?? ""
                Text("\(langName) · \(playlist.proficiencyLevel)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Songs
            if let songs = playlistSongs[playlist.id] {
                ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                    let isPlaying = nowPlayingTitle == song.song.title && nowPlayingPlaylistId == playlist.id
                    Button {
                        nowPlayingTitle = song.song.title
                        nowPlayingArtist = song.song.artist
                        nowPlayingArt = song.song.albumArtUrl
                        nowPlayingPlaylistId = playlist.id
                        openInSpotify(title: song.song.title, artist: song.song.artist, spotifyId: song.song.spotifyId)
                        Task {
                            try? await NetworkManager.shared.updateUserSongProgress(song_id: song.song.id, request_type: "song_listen", playlist_id: playlist.id)
                        }
                    } label: {
                        HStack(spacing: 0) {
                            // Track number or playing indicator
                            Group {
                                if isPlaying {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                } else {
                                    Text("\(index + 1)")
                                        .font(.caption.monospacedDigit())
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 28, alignment: .center)

                            // Album art
                            if let artUrl = song.song.albumArtUrl, let url = URL(string: artUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    songArtPlaceholder
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            } else {
                                songArtPlaceholder
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }

                            // Title & artist
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.song.title)
                                    .font(.subheadline)
                                    .foregroundColor(isPlaying ? .green : .white)
                                    .lineLimit(1)

                                Text(song.song.artist)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            .padding(.leading, 10)

                            Spacer()

                            // Duration
                            Text(durations[index % durations.count])
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 7)
                    }
                }
            } else {
                HStack {
                    Spacer()
                    ProgressView().tint(.green)
                    Spacer()
                }
                .padding(.vertical, 16)
            }

            Divider()
                .background(Color.white.opacity(0.08))
                .padding(.top, 6)
        }
    }

    private var songArtPlaceholder: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.white.opacity(0.08))
            .overlay(
                Image(systemName: "music.note")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.25))
            )
    }

    // MARK: - Data Loading

    func loadAllData() async {
        do {
            let data = try await NetworkManager.shared.fetchPlaylistCollectionData()
            let collections = data.playlistCollections
            self.playlists = collections.recentlyPlayed + collections.newPlaylists + collections.itsBeenAWhile
            self.isLoading = false

            await withTaskGroup(of: (Int, [PlaylistSongEntry]?).self) { group in
                for playlist in playlists {
                    group.addTask {
                        do {
                            let songData = try await NetworkManager.shared.fetchSinglePlaylistData(playlistId: playlist.id)
                            return (playlist.id, songData.playlistSongs)
                        } catch {
                            return (playlist.id, nil)
                        }
                    }
                }
                for await (id, songs) in group {
                    if let songs {
                        self.playlistSongs[id] = songs
                    }
                }
            }
        } catch {
            print("Failed to load playlists: \(error)")
            self.isLoading = false
        }
    }
}

#Preview {
    SpotifyPlayerView()
}
