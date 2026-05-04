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
    
    // Password requirement state
    @State private var isMinLength = false
    @State private var hasLetter = false
    @State private var hasUppercase = false
    @State private var hasSpecialChar = false
    @State private var hasNumber = false

    private var meetsAllRequirements: Bool {
        isMinLength && hasLetter && hasUppercase && hasSpecialChar && hasNumber
    }
    
    @Environment(\.dismiss) var dismiss

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
                                .onChange(of: password) { _, newValue in
                                    let req = ValidationUtils.checkPasswordRequirements(password: newValue)
                                    isMinLength = req.minLen
                                    hasLetter = req.letter
                                    hasUppercase = req.upper
                                    hasSpecialChar = req.special
                                    hasNumber = req.number
                                }
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
                        
                        // The checkmark row Jaci built
                        VStack(alignment: .leading, spacing: 10) {
                            RequirementRow(isMet: isMinLength, text: "At least 8 characters")
                            RequirementRow(isMet: hasLetter, text: "Contains a letter")
                            RequirementRow(isMet: hasUppercase, text: "Contains an uppercase letter")
                            RequirementRow(isMet: hasSpecialChar, text: "Contains a special character")
                            RequirementRow(isMet: hasNumber, text: "Contains a number")
                        }
                        .font(.footnote)
                        .padding(.top, 4)
                    }

                    NavigationLink(value: OnboardingFlow.languageSelectionView) {
                        Text("Create Account")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.486, green: 0.227, blue: 0.929))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.top, 8)
                    .disabled(!(ValidationUtils.isValidEmail(email) && meetsAllRequirements && password == confirmPassword))
                    .opacity((ValidationUtils.isValidEmail(email) && meetsAllRequirements && password == confirmPassword) ? 1.0 : 0.5)

                    VStack(spacing: 8) {
                        Text("Already have an account?")
                            .foregroundColor(.gray)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Sign In")
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
