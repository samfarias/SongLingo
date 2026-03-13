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
        Text("Login")
        
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
    }
}

#Preview {
    Login()
}
