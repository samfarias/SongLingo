//
//  UpdateUserInfo.swift
//  SongLingo
//
//  Created by Jaci on 3/14/26.
//

import SwiftUI

struct UpdateUserInfo: View {
    @Binding var value: String
    var title: String
    var currentPass: String
    
    // To close the screen
    @Environment(\.dismiss) var dismiss
    
    // Old password variables
    @State private var oldPassword: String = ""
    @State private var newValue: String = ""
    @State private var confirmValue: String = ""
    
    // Invalid input message variables
    @State private var showMismatchMessage: Bool = false
    @State private var isEmailInvalid: Bool = false
    @State private var oldPasswordIncorrect: Bool = false
    
    // Password visability (for security) variables
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isOldPasswordVisible: Bool = false
    
    // Password requirement variables
    @State private var isMinLength = false
    @State private var hasLetter = false
    @State private var hasUppercase = false
    @State private var hasSpecialChar = false
    @State private var hasNumber = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Password Update - Adds and handles Old Password TextField
                    VStack(alignment: .leading) {
                        if title == "Password" {
                            Text("Old Password")
                                .font(.headline)
                                .padding(.horizontal, 20)
                            
                            ZStack {
                                HStack {
                                    Group {
                                        if isOldPasswordVisible {
                                            TextField("Old Password", text: $oldPassword)
                                                .textContentType(.password)
                                        } else {
                                            SecureField("Old Password", text: $oldPassword)
                                                .textContentType(.password)
                                        }
                                        
                                        Button(action: {
                                            isOldPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isOldPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                
                                }
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: 45)
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Update title for all fields
                        Text("Update \(title)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                    
                        // New Password Update - Establishes password visibility and password validation
                        if title == "Password" {
                            ZStack {
                                HStack {
                                    Group {
                                        if isPasswordVisible {
                                            TextField("New \(title)", text: $newValue)
                                                .textContentType(.newPassword)
                                        } else {
                                            SecureField("New \(title)", text: $newValue)
                                                .textContentType(.newPassword)
                                        }
                                        
                                        Button(action: {
                                            isPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 45)
                            .padding(.horizontal, 20)
                            .onChange(of: newValue) {
                                checkPasswordRequirements()
                            }
                        } else {
                            TextField("New \(title)", text: $newValue)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    
                        Text("Confirm \(title)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                    
                        // Confirm Password Update - Establishes password visibility and password textField
                        if title == "Password" {
                            ZStack {
                                HStack {
                                    Group {
                                        if isConfirmPasswordVisible {
                                            TextField("Confirm \(title)", text: $confirmValue)
                                                .textContentType(.newPassword)
                                        } else {
                                            SecureField("Confirm \(title)", text: $confirmValue)
                                                .textContentType(.newPassword)
                                        }
                                        
                                        Button(action: {
                                            isConfirmPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 45)
                            .padding(.horizontal, 20)
                            
                        } else {
                            TextField("Confirm \(title)", text: $confirmValue)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                .padding(.horizontal, 20)
                        }
                        // The above else-statement creates the confirm textField for other fields
                    }
                    
                    VStack (spacing: 5) {
                        // Old Password - Error message
                        if oldPasswordIncorrect {
                            Text("Old password is incorrect")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                        }
                        
                        // Mismatched textFields - Error message
                        if showMismatchMessage {
                            Text("\(title) does not match")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                        }
                        
                        // Email Validation - Error message
                        if isEmailInvalid {
                            Text("Invalid email address")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                        }
                        
                    }
                    //Self-Note: The error messages are set before the pasword requirements so it appears before the checklist on the screen. To set them after, just place them after following if-statement.
                    
                    // Password Requirements - Checks if each condition is met
                    if title == "Password" {
                        VStack(alignment: .leading, spacing: 10) {
                            RequirementRow(isMet: isMinLength, text: "At least 8 characters")
                            RequirementRow(isMet: hasLetter, text: "Contains a letter")
                            RequirementRow(isMet: hasUppercase, text: "Contains an uppercase letter")
                            RequirementRow(isMet: hasSpecialChar, text: "Contains a special character")
                            RequirementRow(isMet: hasNumber, text: "Contains a number")
                        }
                        //Self-Note: Using the footnote font might make it look cleaner, but it might be too small? If anything, check this over and see if a customized font size is better.
                        .font(.footnote)
                        .padding(.horizontal, 20)
                    }

                    Button(action: {
                        if title == "Password"{
                            let metReqs = isMinLength && hasLetter && hasUppercase && hasSpecialChar && hasNumber
                            
                            if metReqs {
                                if oldPassword != currentPass {
                                    if newValue == confirmValue && !newValue.isEmpty && !confirmValue.isEmpty {
                                        oldPassword = ""
                                        oldPasswordIncorrect = true
                                        showMismatchMessage = false
                                    } else {
                                        oldPassword = ""
                                        newValue = ""
                                        confirmValue = ""
                                        oldPasswordIncorrect = true
                                        showMismatchMessage = true
                                    }
                                } else {
                                    if newValue == confirmValue && !newValue.isEmpty && !confirmValue.isEmpty {
                                        value = newValue
                                        dismiss()
                                    } else {
                                        oldPasswordIncorrect = false
                                        showMismatchMessage = true
                                        newValue = ""
                                        confirmValue = ""
                                    }
                                }
                            }
                        } else if title == "Email" {
                            if isValidEmail(newValue) {
                                if newValue == confirmValue && !newValue.isEmpty {
                                    isEmailInvalid = false
                                    value = newValue
                                    dismiss()
                                } else {
                                    showMismatchMessage = true
                                    newValue = ""
                                    confirmValue = ""
                                }
                            } else {
                                isEmailInvalid = true
                            }
                        } else {
                            // For other fields (if any are added in the future)
                            if newValue == confirmValue && !newValue.isEmpty {
                                value = newValue
                                dismiss()
                            } else {
                                showMismatchMessage = true
                                newValue = ""
                                confirmValue = ""
                            }
                        }
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 42)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit \(title)")
            .background(Color(.purple).opacity(0.2))
        }
    }
    
    // Password requirements
    func checkPasswordRequirements() {
        isMinLength = newValue.count >= 8
        hasLetter = newValue.range(of: "[A-Za-z]", options: .regularExpression) != nil
        hasUppercase = newValue.range(of: "[A-Z]", options: .regularExpression) != nil
        hasSpecialChar = newValue.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        hasNumber = newValue.range(of: "[0-9]", options: .regularExpression) != nil
    }
}

// Password requirements validation checker
struct RequirementRow: View {
    var isMet: Bool
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark" : "xmark")
                .foregroundColor(isMet ? .green : .red)
                .bold()
            Text(text)
                .foregroundColor(isMet ? .green : .primary)
                .bold()
        }
    }
}

// Function for email validation
func isValidEmail(_ email: String) -> Bool {
    let atCount = email.filter { $0 == "@" }.count
    guard atCount == 1 else { return false }
    guard !email.contains(" ") else { return false }
    if let atIndex = email.firstIndex(of: "@") {
        let domainPart = email[email.index(after: atIndex)...]
        return domainPart.contains(".")
    }
    return false
}

// Preview code (example)
struct Preview: PreviewProvider {
    @State static var sampleValue = "Initial Value"
    
    static var previews: some View {
        NavigationView {
            UpdateUserInfo(value: $sampleValue, title: "Password", currentPass: "Happy123!")
        }
    }
}

