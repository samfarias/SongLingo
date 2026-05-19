//
//  Profile.swift
//  SongLingo
//
//  Created by Jaci on 3/11/26.
//

import SwiftUI
import AuthenticationServices

struct Profile: View {
    // Dummy info fallback
    @State private var demo = UserData(username: "JohnDoe", email: "bob@gmail.com", password: "Password1@", genrePreference: "Rock", languagePreference: "Spanish", languageProficiency: "Beginner", joinDate: "March 2026")

    @State private var homeData: HomeScreenData?
    @AppStorage("spotifyLinked") private var spotifyLinked = false
    @State private var isLinkingSpotify = false
    
    private var liveGenrePreference: String {
        if let genreId = homeData?.suggestedPlaylists.recentlyPlayed.first?.genre {
            return Constants.genreIdToName[genreId] ?? "Genre \(genreId)"
        }
        return demo.genrePreference
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Constants.sunburst.opacity(0.5))
                            .frame(width: 150, height: 100)
                            .overlay(Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 3))
                    
                        Text(String((homeData?.userInfo.firstName ?? demo.username).first!).uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    .padding(.top, 1)
                    
                    VStack(spacing: 5) {
                        Text(homeData?.userInfo.firstName ?? demo.username)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Joined · " + (homeData?.userInfo.joinDate ?? demo.joinDate))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(.vertical, 3)
                            .padding(.horizontal, 14)
                            .background(Constants.sunburst.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    }
                    .padding(.horizontal)
                    
                    
                    LazyVStack(alignment: .leading, spacing: 10) {
                        Text("Preference")
                            .font(.headline)
                            .foregroundColor(Color.white.opacity(0.95))
                        
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Genre")
                                        .foregroundStyle(Color.white.opacity(0.85))
                                        .font(.subheadline)
                                    
                                    // LIVE: Connected dynamic genre resolution
                                    Text(liveGenrePreference)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.95))
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Constants.sunburst.opacity(0.5))
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Language")
                                        .foregroundStyle(Color.white.opacity(0.85))
                                        .font(.subheadline)
                                    
                                    // LIVE: Mapped Language ID to Name
                                    Text(Constants.languageIdToName[homeData?.userInfo.targetLanguage ?? 0] ?? demo.languagePreference)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Constants.sunburst.opacity(0.5))
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Proficiency")
                                        .foregroundStyle(Color.white.opacity(0.85))
                                        .font(.subheadline)
                                    
                                    // LIVE: Connected user proficiency string from backend
                                    Text(homeData?.userInfo.proficiencyLevel ?? demo.languageProficiency)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Constants.sunburst.opacity(0.5))
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .shadow(radius: 4)
                        
                        Spacer()
                        Text("Personal Information")
                            .font(.headline)
                            .foregroundStyle(Color.white.opacity(0.95))
                        
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Email")
                                        .foregroundStyle(Color.white.opacity(0.85))
                                        .font(.subheadline)
                                    Text(String(repeating: "*", count: demo.email.count))
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.95))
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: UpdateUserInfo(value: $demo.email, title: "Email", currentPass: demo.password)) {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.white.opacity(0.9))
                                }
                                
                            }
                            .padding()
                            .background(Constants.sunburst.opacity(0.5))
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Password")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    Text(String(repeating: "*", count: demo.password.count))
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: UpdateUserInfo(value: $demo.password, title: "Password", currentPass: demo.password)) {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.white.opacity(0.9))
                                }
                            }
                            .padding()
                            .background(Constants.sunburst.opacity(0.5))
                            
                            Divider()
                            
                            Button {
                                connectSpotify()
                            } label: {
                                HStack {
                                    HStack(spacing: 8) {
                                        Text(spotifyLinked ? "Spotify Connected" : "Connect to Spotify")
                                            .foregroundStyle(Color.white.opacity(0.5))
                                            .font(.subheadline)

                                        Image(systemName: spotifyLinked ? "checkmark.circle.fill" : "music.note")
                                            .foregroundStyle(spotifyLinked ? .green : Color.white.opacity(0.8))

                                    }

                                    Spacer()

                                    if isLinkingSpotify {
                                        ProgressView()
                                            .tint(.white)

                                    } else if !spotifyLinked {
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Color.white.opacity(0.9))
                                    }
                                }

                                .padding()
                                .background(Constants.sunburst.opacity(0.5))

                            }

                            .disabled(spotifyLinked || isLinkingSpotify)

                        }

                        .background(Color.gray.opacity(0.2))

                        .cornerRadius(20)

                        .shadow(radius: 4)

                        Spacer(minLength: 1)

                        Button {
                            UserDefaults.standard.removeObject(forKey: "jwt_access_token")
                            UserDefaults.standard.removeObject(forKey: "user_id")
                            UserDefaults.standard.removeObject(forKey: "is_new_user")
                            UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Constants.sunburst.opacity(0.45))
                            .cornerRadius(15)
                        }
                    }
                    .padding()
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
                        .offset(x: 10, y: -100)
                        
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
                        .offset(x: -30, y: -10)
                    }
                }
            )
            .task {
                do {
                    self.homeData = try await NetworkManager.shared.fetchHomeScreenData()
                } catch {
                    print("DEBUG: Profile fetch failed with error: \(error)")
                }
            }
        }
    }

    func connectSpotify() {
        isLinkingSpotify = true
        Task {
            do {
                try await SpotifyAuthManager.shared.connect()
                print("DEBUG: Spotify linked successfully")

                try await NetworkManager.shared.syncPlaylistsToSpotify()
                print("DEBUG: Synced playlists to user's Spotify account")

                await MainActor.run { self.homeData = nil }
                self.homeData = try await NetworkManager.shared.fetchHomeScreenData()
            } catch {
                print("DEBUG: Spotify connect error: \(error)")
            }
            await MainActor.run { isLinkingSpotify = false }
        }
    }
}

struct UserData {
    var username: String
    var email: String
    var password: String
    let genrePreference: String
    let languagePreference: String
    let languageProficiency: String
    let joinDate: String
}

#Preview {
    Profile()
}
