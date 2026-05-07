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
    
    @State private var isUsernameValid = false
    @State private var isEmailValid = false
    @State private var isPasswordValid = false
    @State private var isConfirmPasswordValid = false

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
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
                                .padding(.top, 10)
                        }

                        VStack {
                            VStack(alignment: .leading, spacing: 14) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Username")
                                        .fontWeight(.semibold)
                                    
                                    TextField("", text: $username)
                                        .onChange(of: username) {
                                            validateUsername()
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    if !isUsernameValid && !username.isEmpty {
                                        Text("Username must be at least 3 character")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Email")
                                        .fontWeight(.semibold)
                                    
                                    TextField("", text: $email)
                                        .onChange(of: email) {
                                            validateEmail()
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    if !isEmailValid && !email.isEmpty {
                                        Text ("Enter a valid email")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Password")
                                        .fontWeight(.semibold)
                                    
                                    SecureField("", text: $password)
                                        .onChange(of: password) {
                                            validatePassword()
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    if !isPasswordValid && !password.isEmpty {
                                        Text ("Password does not match")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Confirm Password")
                                        .fontWeight(.semibold)
                                    
                                    SecureField("", text: $confirmPassword)
                                        .onChange(of: confirmPassword) {
                                            validateConfirmPassword()
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    if !isConfirmPasswordValid && !confirmPassword.isEmpty {
                                        Text("Passwords do not match")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                            }
                        }

                        
                        NavigationLink(destination: LangSelectionView()) {
                            Text("Create Account")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.top, 10)
                        .opacity(isFormValid ? 1.0 : 0.5)
                        .disabled(!isFormValid)

                        VStack(spacing: 8) {
                            Text("Already have an account?")
                                .foregroundColor(.gray)
                                .padding(5)


                            Button("Sign In") {
                                dismiss()
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
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
    
    private var isFormValid: Bool {
        return isUsernameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid
    }
    
    private func validateUsername() {
        isUsernameValid = !username.isEmpty && username.count >= 3
    }
    
    private func validateEmail() {
        let emailConditions = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailConditions).evaluate(with: email) && !email.isEmpty
    }
    
    private func validatePassword() {
        let passwordConditions = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[#$@!%&*?])[A-Za-z\\d#$@!%&*?]{8,}$"
        isPasswordValid = NSPredicate(format: "SELF MATCHES %@", passwordConditions).evaluate(with: password) && !password.isEmpty
        validateConfirmPassword()
    }
    
    private func validateConfirmPassword() {
        isConfirmPasswordValid = (password == confirmPassword && !confirmPassword.isEmpty)
    }
}

#Preview {
    CreateAccView()
}
