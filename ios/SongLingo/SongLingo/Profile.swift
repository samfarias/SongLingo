//
//  Profile.swift
//  SongLingo
//
//  Created by Jaci on 3/11/26.
//

import SwiftUI

struct Profile: View {
    //Dummy info
    @State private var demo = UserData(username: "JohnDoe", email: "bob@gmail.com", password: "Password1@", genrePreference: "Rock", languagePreference: "Spanish", languageProficiency: "Beginner", joinDate: "March 2026")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    //Sets up icon w/ initials
                    ZStack {
                        //Creates gradient circle
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.purple.opacity(0.5), .purple.opacity(0.75),.purple, .indigo]), startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 150, height: 100)
                            .overlay(Circle()
                                .stroke(Color.purple.opacity(0.8), lineWidth: 3))
                        
                        Text(demo.username.first!.uppercased())
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white)
                    }
                    .padding(.top, 1)
                    
                    // Sets up name under icon w/ join date
                    VStack(spacing: 5) {
                        // Displays user's first and last name
                        Text(demo.username)
                            .font(.title2)
                            .bold(true)
                            .foregroundColor(.primary)
                        
                        // Displays the join date under name
                        Text("Joined · " + demo.joinDate)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.purple.opacity(0.8))
                            .padding(.vertical, 3)
                            .padding(.horizontal, 14)
                            .background(Color.purple.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(alignment: .leading, spacing: 10) {
                        Text("Preference")
                            .font(.headline)
                        
                        VStack(spacing: 0) {
                            
                            // Genre Preference information
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Genre")
                                        .foregroundStyle(Color.gray)
                                        .font(.subheadline)
                                    Text(demo.genrePreference)
                                        .font(.callout)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            
                            Divider()
                            
                            // Language Preference information
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Language")
                                        .foregroundStyle(Color.gray)
                                        .font(.subheadline)
                                    Text(demo.languagePreference)
                                        .font(.callout)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            
                            Divider() // line separator
                            
                            // Language Proficiency row
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Proficiency")
                                        .foregroundStyle(Color.gray)
                                        .font(.subheadline)
                                    Text(demo.languageProficiency)
                                        .font(.callout)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .shadow(radius: 4)
                        
                        Spacer()
                        Text("Personal Information")
                            .font(.headline)
                        
                        VStack(spacing: 0) {
                            HStack {
                                // Displays Email information
                                VStack(alignment: .leading) {
                                    Text("Email")
                                        .foregroundStyle(Color.gray)
                                        .font(.subheadline)
                                    Text(demo.email)
                                        .font(.callout)
                                }
                                Spacer()
                                NavigationLink(destination: UpdateUserInfo(value: $demo.email, title: "Email", currentPass: demo.password)) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            
                            Divider()
                            
                            HStack {
                                // Displays Password information
                                VStack(alignment: .leading) {
                                    Text("Password")
                                        .foregroundStyle(Color.gray)
                                        .font(.subheadline)
                                    // Text(demo.password)
                                    // The following is to obscure the password
                                    Text(String(repeating: "*", count: demo.password.count))
                                        .font(.callout)
                                }
                                Spacer()
                                NavigationLink(destination: UpdateUserInfo(value: $demo.password, title: "Password", currentPass: demo.password)) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .shadow(radius: 4)
                    }
                    .padding()
                }
                // .background(Color(UIColor.systemBackground))
                .navigationTitle("Profile")
            }
            // This coverrs the background to the whole screen
            .background(Color(.purple).opacity(0.2))
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
