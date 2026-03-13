//
//  Login.swift
//  SongLingo
//
//  Created by Derek Huang on 3/10/26.
//

import SwiftUI

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
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
                
                Text("SongLingo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Learn languages through the music you love")
                    .foregroundColor(.white)
            
                VStack(spacing: 20) {
            
                Text("Welcome Back")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                Text("Sign in to continue your journey")
                        .foregroundColor(.gray)
                
                    VStack(alignment: .leading, spacing: 15) {
                        
                        Text("Email")
                            .fontWeight(.semibold)
                        
                        TextField("", text: $email)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .cornerRadius(10)
                        
                        Text("Password")
                            .fontWeight(.semibold)
                        
                        SecureField("", text: $password)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .cornerRadius(10)
                        
                        Text("Don't have an account?")
                    }
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(25)
                .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    Login()
}
