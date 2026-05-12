//
//  Profile.swift
//  SongLingo
//
//  Created by Jaci on 3/11/26.
//

import SwiftUI

struct Profile: View {
    // Dummy info fallback
    @State private var demo = UserData(username: "JohnDoe", email: "bob@gmail.com", password: "Password1@", genrePreference: "Rock", languagePreference: "Spanish", languageProficiency: "Beginner", joinDate: "March 2026")
    
    // NEW: Live backend data holder
    @State private var homeData: HomeScreenData?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Sets up icon w/ initials
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.4), .white.opacity(0.1), .indigo.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 150, height: 100)
                            .overlay(Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 3))
                        
                        // LIVE: Pulls the first letter of the live first name
                        Text(String((homeData?.userInfo.firstName ?? demo.username).first!).uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    .padding(.top, 1)
                    
                    VStack(spacing: 5) {
                        // LIVE: Displays live first name
                        Text(homeData?.userInfo.firstName ?? demo.username)
                            .font(.title2)
                            .bold(true)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // LIVE: Displays the real join date from Django
                        Text("Joined · " + (homeData?.userInfo.joinDate ?? demo.joinDate))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(.vertical, 3)
                            .padding(.horizontal, 14)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(alignment: .leading, spacing: 10) {
                        Text("Preference")
                            .font(.headline)
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Genre")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    Text(demo.genrePreference)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.25))
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Language")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    // LIVE: Mapped Language ID to Name
                                    Text(Constants.languageIdToName[homeData?.userInfo.targetLanguage ?? 0] ?? demo.languagePreference)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.25))
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Proficiency")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    // LIVE: Real Proficiency Level
                                    Text(homeData?.userInfo.proficiencyLevel ?? demo.languageProficiency)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.25))
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .shadow(radius: 4)
                        
                        Spacer()
                        Text("Personal Information")
                            .font(.headline)
                            .foregroundStyle(Color.white.opacity(0.8))
                        
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Email")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    Text(demo.email)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                Spacer()
                                NavigationLink(destination: UpdateUserInfo(value: $demo.email, title: "Email", currentPass: demo.password)) {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.white.opacity(0.9))
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            
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
                            .background(Color.white.opacity(0.2))
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .shadow(radius: 4)
                    }
                    .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Profile")
                            .foregroundColor(Color.white.opacity(0.8))
                            .font(.headline)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.750, green: 0.355, blue: 0.550),
                        Color(red: 0.576, green: 0.400, blue: 0.918),
                        Color(red: 0.231, green: 0.027, blue: 0.592)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            // LIVE: Fetching the data when the screen appears
            .task {
                let userID = UserDefaults.standard.string(forKey: "user_id") ?? "1"
                do {
                    self.homeData = try await NetworkManager.shared.fetchHomeScreenData(userId: userID)
                } catch {
                    print("DEBUG: Profile fetch failed with error: \(error)")
                }
            }
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
