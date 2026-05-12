//
//  Profile.swift
//  SongLingo
//
//  Created by Jaci on 3/11/26.
//

import SwiftUI

struct Profile: View {
    //Dummy/ fallback info
    @State private var demo = UserData(username: "JohnDoe", email: "bob@gmail.com", password: "Password1@", genrePreference: "Rock", languagePreference: "Spanish", languageProficiency: "Beginner", joinDate: "March 2026")
    
    @State private var homeData: HomeScreenData?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    //Sets up icon w/ initials
                    ZStack {
                        //Creates gradient circle
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.4), .white.opacity(0.1), .indigo.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 150, height: 100)
                            .overlay(Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 3))
                        
                        Text(String((homeData?.userInfo.firstName ?? demo.username).first!).uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    .padding(.top, 1)
                    
                    // Sets up name under icon w/ join date
                    VStack(spacing: 5) {
                        // Displays user's first and last name
                        Text(homeData?.userInfo.firstName ?? demo.username)
                            .font(.title2)
                            .bold(true)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Displays the join date under name
                        // Text("Joined · " + (homeData?.userInfo.joinDate ?? demo.joinDate))
                        Text("Joined · " + demo.joinDate)
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
                            
                            // Genre Preference information
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Genre")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    //Needs to be changed!!
                                    Text(demo.genrePreference)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.25))
                            
                            Divider()
                            
                            // Language Preference information
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Language")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    Text(Constants.languageIdToName[homeData?.userInfo.targetLanguage ?? 0] ?? demo.languagePreference)
                                        .font(.callout)
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.25))
                            
                            Divider() // line separator
                            
                            // Language Proficiency row
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Proficiency")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
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
                                // Displays Email information
                                VStack(alignment: .leading) {
                                    Text("Email")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    //Needs changing
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
                                // Displays Password information
                                VStack(alignment: .leading) {
                                    Text("Password")
                                        .foregroundStyle(Color.white.opacity(0.5))
                                        .font(.subheadline)
                                    // Text(demo.password)
                                    // The following is to obscure the password
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
            
            // This coverrs the background to the whole screen
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


#Preview {
    Profile()
}
