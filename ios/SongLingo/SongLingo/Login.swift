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
            
            VStack(spacing: 20) {
                
                Text("SongLingo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Learn languages through the music you love")
                    
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
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    Text("Password")
                        .fontWeight(.semibold)
                    
                    SecureField("", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    Text("Don't have an account?")
                }
            }
        }
    }
}

#Preview {
    Login()
}
