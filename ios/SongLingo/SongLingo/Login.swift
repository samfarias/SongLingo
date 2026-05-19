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
                            Color.red.opacity(0.25),
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
                            Color.red.opacity(0.25),
                                .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 200
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: 200, y: -10)
                }
                
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
                            .foregroundColor(.white)
                        
                        Text("Sign in to continue your journey")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Username")
                                .fontWeight(.semibold)
                            
                            TextField("", text: $username)
                                .padding()
                                .background(.white.opacity(0.55))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .autocapitalization(.none)
                            
                            Text("Password")
                                .fontWeight(.semibold)
                            
                            SecureField("", text: $password)
                                .padding()
                                .background(.white.opacity(0.55))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                            
                            Text("")
                            
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
                                    .background(LinearGradient(
                                        colors: [
                                            Color(red: 0.250, green: 0.150, blue: 0.920),
                                            Color(red: 0.655, green: 0.195, blue: 0.950),
                                            Color(red: 0.985, green: 0.165, blue: 0.555)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 10)
                            
                            NavigationLink(destination: CreateAccView()) {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(LinearGradient(
                                        colors: [
                                            Color(red: 0.250, green: 0.150, blue: 0.920),
                                            Color(red: 0.655, green: 0.195, blue: 0.950),
                                            Color(red: 0.985, green: 0.165, blue: 0.555)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(25)
                    .background(Color.white.opacity(0.09))
                    .foregroundColor(.white)
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
