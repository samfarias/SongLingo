//
//  CreateAccView.swift
//  SongLingo
//
//  Created by Derek Huang on 3/21/26.
//

import SwiftUI

struct CreateAccView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
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
                    
                Text("Start Your SongLingo Journey")
                        .foregroundColor(.gray)
                
                    VStack(alignment: .leading, spacing: 15) {
                        
                        Text("Username")
                            .fontWeight(.semibold)
                        
                        TextField("", text: $username)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .cornerRadius(10)
                        
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
                        
                        Text("Confirm Password")
                            .fontWeight(.semibold)
                        
                        SecureField("", text: $confirmPassword)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .cornerRadius(10)
                        
                        Button("Create Account") {
                            print("Create account tapped")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                        
                        Button("Sign In") {
                            print("Sign In tapped")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                        .foregroundColor(.white)
                        .cornerRadius(12)
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
    CreateAccView()
}
