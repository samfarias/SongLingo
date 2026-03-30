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
                    Color(red: 0.231, green: 0.027, blue: 0.392)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("♪ SongLingo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Learn languages through the music you love")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.top, 40)

                VStack(spacing: 18) {
                    VStack(spacing: 6) {
                        Text("Create Account")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Join SongLingo and start learning today")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username")
                                .fontWeight(.semibold)

                            TextField("", text: $username)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .fontWeight(.semibold)

                            TextField("", text: $email)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .fontWeight(.semibold)

                            SecureField("", text: $password)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Confirm Password")
                                .fontWeight(.semibold)

                            SecureField("", text: $confirmPassword)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }

                    Button("Create Account") {
                        print("Create account tapped")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.top, 8)

                    VStack(spacing: 8) {
                        Text("Already have an account?")
                            .foregroundColor(.gray)

                        Button("Sign In") {
                            print("Sign In tapped")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(25)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

#Preview {
    CreateAccView()
}
