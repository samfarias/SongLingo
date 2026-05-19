import SwiftUI

struct Dashboard: View {
    @State private var homeData: HomeScreenData?
    @State private var isNewUser = false
    @State private var streakDayFormat = "days"

    @AppStorage("last_playlist_generation_date") private var lastGeneratedDateString: String = ""
    @AppStorage("daily_playlist_id") private var dailyPlaylistId: String = ""
    @AppStorage("spotifyLinked") private var spotifyLinked = false
    @State private var navigateToPlaylist = false
    @State private var isLinkingSpotify = false
    
    private var hasGeneratedToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        return lastGeneratedDateString == todayString
    }
    
    var body: some View {
        NavigationStack {
            ScrollView (.vertical, showsIndicators: true) {
                ZStack {
                    VStack {
                        ZStack {
                            GeometryReader { geometry in
                                ZStack {
                                    ForEach(0..<10, id: \.self) { _ in
                                        Circle()
                                            .fill(.white)
                                            .frame(width: CGFloat.random(in: 1.5...3), height: CGFloat.random(in: 1.5...3))
                                            .opacity(Double.random(in: 0.1...0.9))
                                            .position(
                                                x: CGFloat.random(in: 0...geometry.size.width),
                                                y: CGFloat.random(in: 0...geometry.size.height)
                                            )
                                    }
                                    
                                    ForEach(0..<5, id: \.self) { i in
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
                            .ignoresSafeArea()
                            .blur(radius: 6)
                        }

                        Spacer()
                        
                        Text("\(isNewUser ? "Welcome" : "Welcome Back"), \(homeData?.userInfo.firstName ?? "User")!")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.title.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        Text("You're learning \(Constants.languageIdToName[homeData?.userInfo.targetLanguage ?? 0] ?? "Language name") · \(homeData?.userInfo.proficiencyLevel ?? "Proficiency Level")")
                            .foregroundColor(.white.opacity(0.95))
                            .font(.footnote.weight(.light))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                    }
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, minHeight: 135)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ).opacity(0.25)
                    )
                }
                
                Spacer(minLength: 10)
                
                HStack (spacing: 10) {
                    NavigationLink(destination: WordBank()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.sunburst.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                                )
                            
                            HStack {
                                Image(systemName: "book")
                                    .padding(4)
                                    .foregroundColor(.white.opacity(0.95))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                                    )
                                    .font(.system(size: 12))
                                VStack (alignment: .leading) {
                                    Text("Word Bank")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                    
                                    Text ("(\(homeData?.userProgress.numWordsLearned ?? 0))")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 8))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                        }
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 3, y: 3)
                        .frame(maxWidth: .infinity)
                    }
                    
                    NavigationLink(destination: MySongs()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.sunburst.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                                )
                            
                            HStack {
                                Image(systemName: "music.note.square.stack")
                                    .padding(4)
                                    .foregroundColor(.white.opacity(0.95))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                                    )
                                    .font(.system(size: 12))
                                
                                VStack (alignment: .leading) {
                                    Text("My Songs")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                    
                                    Text ("(\(homeData?.userProgress.numSongsCompleted ?? 0))")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 8))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                        }
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 3, y: 3)
                        .frame(maxWidth: .infinity)
                    }
                    
                    NavigationLink(destination: UserActivity()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.sunburst.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                                )
                            
                            HStack {
                                Image(systemName: "flame.fill")
                                    .padding(4)
                                    .foregroundColor(.white.opacity(0.85))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.55), lineWidth: 1)
                                    )
                                    .font(.system(size: 12))
                                
                                VStack (alignment: .leading) {
                                    Text("Streak")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                    
                                    Text ("\(homeData?.userProgress.currentStreak ?? 0) \(self.streakDayFormat)!")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 8))
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 15)
                        }
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 3, y: 3)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)

                if !spotifyLinked {
                    Button {
                        isLinkingSpotify = true
                        Task {
                            do {
                                try await SpotifyAuthManager.shared.connect()
                                try await NetworkManager.shared.generateSpotifyDrop()
                                self.homeData = try await NetworkManager.shared.fetchHomeScreenData()
                            } catch {
                                print("DEBUG: Spotify link error: \(error)")
                            }
                            isLinkingSpotify = false
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "music.note.tv")
                                .font(.title2)
                                .foregroundColor(.green)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Link your Spotify")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Unlock personalized playlists!")
                                    .font(.caption)
                                    .lineLimit(1)
                                    .foregroundColor(.white.opacity(0.95))
                            }

                            Spacer()

                            if isLinkingSpotify {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Constants.sunburst.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.green.opacity(0.4), lineWidth: 4)
                        )
                        .cornerRadius(15)
                    }
                    .disabled(isLinkingSpotify)
                    .padding(.horizontal)
                    .padding(.vertical, 1)
                }

                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Current Playlists")
                                .foregroundColor(.white.opacity(0.95))
                                .font(.headline)

                            Spacer()

                            Button {
                                Task {
                                    do {
                                        let _ = try await NetworkManager.shared.generateNewPlaylist()
                                        self.homeData = try await NetworkManager.shared.fetchHomeScreenData()
                                    } catch {
                                        print("Error generating playlist: \(error)")
                                    }
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 15)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(homeData?.suggestedPlaylists.allSuggestedPlaylists ?? []) { playlist in
                                    NavigationLink(destination: PlaylistCollection()) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.white.opacity(0.2))
                                            
                                            VStack(spacing: 8) {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(Color.white.opacity(0.95))
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .padding(.vertical, 8)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                                                    )
                                                
                                                Text(playlist.playlistName)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .lineLimit(3)
                                                    .multilineTextAlignment(.center)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                
                                                Spacer()
                                                
                                                Text("\(Constants.languageIdToName[playlist.language] ?? "ID") · \(playlist.proficiencyLevel)")
                                                    .font(.system(size: 9))
                                                
                                                Text("\(Constants.genreIdToName[playlist.genre ?? 0] ?? "Multi-Genre")")
                                                    .font(.system(size: 9))
                                            }
                                            .foregroundColor(Color.white.opacity(0.95))
                                            .padding(10)
                                        }
                                        .frame(width: 110, height: 150)
                                        .shadow(color: Color(red: 0.4, green: 0.6, blue: 0.5).opacity(0.3), radius: 5, x: 3, y: 3)
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 30)
                            .padding(.top, 1)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Constants.sunburst.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.25), lineWidth: 3)
                    )

                    
                    VStack (alignment: .leading) {
                        Text("Today's Daily Playlist")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.95))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Constants.sunburst.opacity(0.4))
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(hasGeneratedToday ? "Your daily playlist is ready!" : "Fresh new songs waiting for you!")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 14))
                                    
                                    Spacer(minLength: 1)
                                    
                                    Text("A playlist a day keeps the locals blown away")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 10, weight: .light, design: .rounded))
                                }
                                .padding(.horizontal, 10)
                                
                                Spacer()
                                
                                Button(action: {
                                    if hasGeneratedToday {
                                        navigateToPlaylist = true
                                    } else {
                                        Task {
                                            do {
                                                let dailyPlaylist = try await NetworkManager.shared.generateNewPlaylist()
                                                self.homeData = try await NetworkManager.shared.fetchHomeScreenData()
                                                
                                                let formatter = DateFormatter()
                                                formatter.dateFormat = "yyyy-MM-dd"
                                                lastGeneratedDateString = formatter.string(from: Date())
                                                dailyPlaylistId = String(dailyPlaylist.id)
                                            } catch {
                                                print("Error generating new playlist \(error)")
                                            }
                                        }
                                    }
                                }) {
                                    Text(hasGeneratedToday ? "Listen Now" : "Generate")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 12))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.35),
                                            Color.clear
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 4)
                                )
                                .cornerRadius(8)
                            }
                            .padding()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.20), lineWidth: 6)
                        )
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.10), radius: 4, x: 5, y: 5)
                    }
                    .padding(.top, 5)
                    
                    VStack (alignment: .leading) {
                        Text("Practice Games")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.95))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Constants.sunburst.opacity(0.4))
                            HStack {
                                VStack (alignment: .leading) {
                                    Text("Ready to test your vocabulary?")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 14))
                                    
                                    Spacer(minLength: 1)
                                    
                                    Text("Take a quiz on words from your completed songs")
                                        .foregroundColor(.white.opacity(0.95))
                                        .font(.system(size: 10, weight: .light, design: .rounded))
                                }
                                .padding(.horizontal, 10)
                                
                                Spacer()
                                
                                NavigationLink(destination: PracticeGameOptions()) {
                                    Text("Practice")
                                        .foregroundStyle(Color.white)
                                        .font(.system(size: 12))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.35),
                                            Color.clear
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 4)
                                )
                                .cornerRadius(8)
                            }
                            .padding()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.20), lineWidth: 6)
                        )
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 5, y: 5)
                    }
                    .padding(.top, 5)
                }
                .padding()
            }
            .background(
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
                                Color.red.opacity(0.25),
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
                                Color.red.opacity(0.25),
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
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $navigateToPlaylist) {
                SinglePlaylistView(playlistId: Int(dailyPlaylistId) ?? -1)
            }
            .ignoresSafeArea()
            .task {
                isNewUser = UserDefaults.standard.bool(forKey: "is_new_user")
                UserDefaults.standard.removeObject(forKey: "is_new_user")
                do {
                    self.homeData = try await NetworkManager.shared.fetchHomeScreenData()
                    self.streakDayFormat = self.homeData?.userProgress.currentStreak == 1 ? "day" : "days"
                } catch {
                    print("DEBUG: Profile fetch failed with error: \(error)")
                }
            }
//            Button("Debug: Reset Daily Limit") {
//                lastGeneratedDateString = "" // Clears the app storage state
//            }
        }
    }
}

struct PlaylistTheme {
    let background: LinearGradient
    let foreground: Color
}

func themeForPlaylist(_ playlist: Playlist) -> PlaylistTheme {
    if playlist.playlistName.contains("Daily Mix") {
        return PlaylistTheme(
            background: Constants.gold,
            foreground: Color.black.opacity(0.7)
        )
    }
    return PlaylistTheme(
        background: Constants.mint,
        foreground: Color(red: 0.1, green: 0.3, blue: 0.2)
    )
}

#Preview {
    Dashboard()
}
