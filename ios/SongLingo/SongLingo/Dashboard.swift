import SwiftUI

struct Dashboard: View {
    @State private var homeData: HomeScreenData?
    @State private var isNewUser = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack (alignment: .top) {
                    VStack {
                        Spacer()
                        
                        Text("\(isNewUser ? "Welcome" : "Welcome Back"), \(homeData?.userInfo.firstName ?? "User")!")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.title.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        Text("You're learning \(Constants.languageIdToName[homeData?.userInfo.targetLanguage ?? 0] ?? "Language name") · \(homeData?.userInfo.proficiencyLevel ?? "Proficiency Level")")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.footnote.weight(.light))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.2),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                Spacer(minLength: 30)
                
                HStack (spacing: 10) {
                    NavigationLink(destination: WordBank()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Constants.blue)
                            HStack {
                                Image(systemName: "book")
                                    .padding(4)
                                    .foregroundColor(.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .font(.system(size: 12))
                                VStack (alignment: .leading) {
                                    Text("Word Bank")
                                        .foregroundColor(.black)
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                    
                                    Text ("(\(homeData?.userProgress.numWordsLearned ?? 0))")
                                        .foregroundColor(.black)
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
                                .fill(Constants.lavender)
                            HStack {
                                Image(systemName: "music.note.square.stack")
                                    .padding(4)
                                    .foregroundColor(.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .font(.system(size: 12))
                                
                                VStack (alignment: .leading) {
                                    Text("My Songs")
                                        .foregroundColor(.black)
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                    
                                    Text ("(\(homeData?.userProgress.numSongsCompleted ?? 0))")
                                        .foregroundColor(.black)
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
                                .fill(Constants.sunburst)
                            HStack {
                                Image(systemName: "flame.fill")
                                    .padding(4)
                                    .foregroundColor(.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .font(.system(size: 12))
                                
                                VStack (alignment: .leading) {
                                    Text("Streak")
                                        .foregroundColor(.black)
                                        .font(.system(size: 10))
                                        .lineLimit(1)
                                    
                                    Text ("\(homeData?.userProgress.currentStreak ?? 0) days!")
                                        .foregroundColor(.black)
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
                
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Current Playlists")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.headline)
                            .padding(.leading, 15)
                            .padding(.top, 15)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(homeData?.suggestedPlaylists.allSuggestedPlaylists ?? []) { playlist in
                                    NavigationLink(destination: PlaylistCollection()) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Constants.mint)
                                            
                                            VStack(spacing: 8) {
                                                Image(systemName: "play.circle.fill")
                                                    .font(.system(size: 28))
                                                    .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.2))
                                                
                                                Text(playlist.playlistName)
                                                    .font(.system(size: 13, weight: .bold))
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                                
                                                Spacer()
                                                
                                                Text("\(Constants.languageIdToName[playlist.language] ?? "ID") · \(playlist.proficiencyLevel)")
                                                    .font(.system(size: 9))
                                                
                                                Text("\(Constants.genreIdToName[playlist.genre ?? 0] ?? "Unknown")")
                                                    .font(.system(size: 9))
                                            }
                                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.2))
                                            .padding(12)
                                        }
                                        .frame(width: 110, height: 150)
                                        .shadow(color: Color(red: 0.4, green: 0.6, blue: 0.5).opacity(0.3), radius: 5, x: 3, y: 3)
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 30)
                            .padding(.top, 5)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.25), lineWidth: 3)
                    )
                    
                    VStack (alignment: .leading) {
                        Text("This Week's Word Cards")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.05))
                            HStack {
                                VStack (alignment: .leading) {
                                    Text("_ new words waiting for you!")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 14))
                                    
                                    Spacer(minLength: 1)
                                    
                                    Text("Complete your daily practice to maintain your streak")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 10, weight: .light, design: .rounded))
                                }
                                .padding(.horizontal, 10)
                                
                                Spacer()
                                
                                Button(action: { }) {
                                    Text("Begin")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 12))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.2),
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
                    .padding(.vertical)
                    
                    VStack (alignment: .leading) {
                        Text("Practice Games")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.03))
                            HStack {
                                VStack (alignment: .leading) {
                                    Text("Ready to test your vocabulary?")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 14))
                                    
                                    Spacer(minLength: 1)
                                    
                                    Text("Take a quiz on words from your completed songs")
                                        .foregroundColor(.white.opacity(0.8))
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
                                            Color.white.opacity(0.2),
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
                    .padding(.vertical)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.300, green: 0.225, blue: 0.520),
                        Color(red: 0.150, green: 0.350, blue: 0.550),
                        Color(red: 0.050, green: 0.355, blue: 0.250),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .task {
                print("\(dataFilePath())")
                isNewUser = UserDefaults.standard.bool(forKey: "is_new_user")
                UserDefaults.standard.removeObject(forKey: "is_new_user")
                do {
                    self.homeData = try await NetworkManager.shared.fetchHomeScreenData()
                } catch {
                    print("DEBUG: Profile fetch failed with error: \(error)")
                }
            }
        }
    }
}

#Preview {
    Dashboard()
}
