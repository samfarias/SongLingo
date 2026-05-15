//
//  Login.swift
//  SongLingo
//
//  Created by Derek Huang on 3/10/26.
//

import SwiftUI

struct Login: View {
    @State private var username = ""
    @State private var password = ""
    @State private var navigateToHome = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.984, green: 0.443, blue: 0.522),
                        Color(red: 0.576, green: 0.200, blue: 0.918),
                        Color(red: 0.231, green: 0.027, blue: 0.392)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    VStack(spacing: 6) {
                        Text("♪ SongLingo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Learn languages through the music you love")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 20) {
                        
                        Text("Welcome Back")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Sign in to continue your journey")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Username")
                                .fontWeight(.semibold)
                            
                            TextField("", text: $username)
                                .padding()
                                .background(.gray.opacity(0.2))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                            
                            Text("Password")
                                .fontWeight(.semibold)
                            
                            SecureField("", text: $password)
                                .padding()
                                .background(.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            Text("Forgot Password?")
                                .foregroundColor(Color(red: 0.486, green: 0.227, blue: 0.929))
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                            }
                            
                            Button(action: handleLogin) {
                                Text("Sign in")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 10)
                            
                            NavigationLink(destination: CreateAccView()) {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(25)
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.horizontal, 30)
                }
            }
            //this listens for navigateToHome to become true, then slides to ContentView
            .navigationDestination(isPresented: $navigateToHome) {
                ContentView()
            }
        }
    }
    func handleLogin() {
        errorMessage = nil
        Task {
            do {
                // 1. Tell the server who is trying to log in
                let response = try await NetworkManager.shared.login(username: username, password: password)
                
                // 2. SAVE the real ID to the backpack!
                // We use String() because your Dashboard is looking for a string.
                UserDefaults.standard.set(String(response.user_id), forKey: "user_id")
                
                print("DEBUG: Successfully saved User ID: \(response.user_id)")
                
                // doorway to dashboard
                navigateToHome = true
                
            } catch {
                print("DEBUG: Login failed: \(error)")
                await MainActor.run {
                    errorMessage = "Invalid username or password."
                }
            }
        }
    }
}
#Preview {
    Login()
}
