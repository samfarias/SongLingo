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
    
    @Environment(\.dismiss) var dismiss
    
    @State private var oldPassword: String = ""
    @State private var newValue: String = ""
    @State private var confirmValue: String = ""
    
    @State private var showMismatchMessage: Bool = false
    @State private var isEmailInvalid: Bool = false
    @State private var oldPasswordIncorrect: Bool = false
    
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var isOldPasswordVisible: Bool = false
    
    @State private var isMinLength = false
    @State private var hasLetter = false
    @State private var hasUppercase = false
    @State private var hasSpecialChar = false
    @State private var hasNumber = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        if title == "Password" {
                            Text("Old Password")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ZStack {
                                HStack {
                                    Group {
                                        if isOldPasswordVisible {
                                            TextField("", text: $oldPassword, prompt: Text("Old Password")
                                                .foregroundColor(.white.opacity(0.8)))
                                                .textContentType(.password)
                                        } else {
                                            SecureField("", text: $oldPassword, prompt: Text("Old Password")
                                                .foregroundColor(.white.opacity(0.8)))
                                                .textContentType(.password)
                                        }
                                        
                                        Button(action: {
                                            isOldPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isOldPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Constants.sunburst.opacity(0.6))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 45)
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Text("Update \(title)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                    
                        if title == "Password" {
                            ZStack {
                                HStack {
                                    Group {
                                        if isPasswordVisible {
                                            TextField("", text: $newValue, prompt: Text("New \(title)").foregroundColor(.white.opacity(0.8)))
                                                .textContentType(.newPassword)
                                                .foregroundColor(.white)
                                        } else {
                                            SecureField("", text: $newValue, prompt: Text("New \(title)").foregroundColor(.white.opacity(0.8)))
                                                .textContentType(.newPassword)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Button(action: {
                                            isPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Constants.sunburst.opacity(0.6))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 45)
                            .padding(.horizontal, 20)
                            .onChange(of: newValue) {
                                checkPasswordRequirements()
                            }
                        } else {
                            TextField("", text: $newValue, prompt: Text("New \(title)").foregroundColor(.white.opacity(0.8)))
                                .padding(10)
                                .background(Constants.sunburst.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    
                        Text("Confirm \(title)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                    
                        if title == "Password" {
                            ZStack {
                                HStack {
                                    Group {
                                        if isConfirmPasswordVisible {
                                            TextField("", text: $confirmValue, prompt: Text("Confirm \(title)").foregroundColor(.white.opacity(0.8)))
                                                .textContentType(.newPassword)
                                                .foregroundColor(.white)
                                        } else {
                                            SecureField("", text: $confirmValue, prompt: Text("Confirm \(title)").foregroundColor(.white.opacity(0.8)))
                                                .textContentType(.newPassword)
                                                .foregroundColor(.white)
                                        }
                                        
                                        Button(action: {
                                            isConfirmPasswordVisible.toggle()
                                        }) {
                                            Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Constants.sunburst.opacity(0.6))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 45)
                            .padding(.horizontal, 20)
                            
                        } else {
                            TextField("", text: $confirmValue, prompt: Text("Confirm \(title)").foregroundColor(.white.opacity(0.8)))
                                .padding(10)
                                .background(Constants.sunburst.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .shadow(radius: 3)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    VStack (spacing: 5) {
                        if oldPasswordIncorrect {
                            Text("Old password is incorrect")
                                .foregroundColor(.red.opacity(0.8))
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                        }
                        
                        if showMismatchMessage {
                            Text("\(title) does not match")
                                .foregroundColor(.red.opacity(0.8))
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                        }
                        
                        if isEmailInvalid {
                            Text("Invalid email address")
                                .foregroundColor(.red.opacity(0.8))
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                        }
                    }
                    
                    if title == "Password" {
                        VStack(alignment: .leading, spacing: 10) {
                            RequirementRow(isMet: isMinLength, text: "At least 8 characters")
                            RequirementRow(isMet: hasLetter, text: "Contains a letter")
                            RequirementRow(isMet: hasUppercase, text: "Contains an uppercase letter")
                            RequirementRow(isMet: hasSpecialChar, text: "Contains a special character")
                            RequirementRow(isMet: hasNumber, text: "Contains a number")
                        }
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
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 42)
                            .background(LinearGradient(
                                colors: [
                                    Color(red: 0.250, green: 0.150, blue: 0.920),
                                    Color(red: 0.655, green: 0.195, blue: 0.950),
                                    Color(red: 0.985, green: 0.165, blue: 0.555)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    Spacer()
                }
                .padding(.top, 20)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit \(title)")
                        .foregroundColor(Color.white.opacity(0.8))
                        .font(.headline)
                }
            }
            .background (
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
                            ForEach(0..<150, id: \.self) { _ in
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
                        .offset(x: 10, y: -100)
                        
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
                        .offset(x: -30, y: -10)
                    }
                }
            )
        }
    }
    
    func checkPasswordRequirements() {
        isMinLength = newValue.count >= 8
        hasLetter = newValue.range(of: "[A-Za-z]", options: .regularExpression) != nil
        hasUppercase = newValue.range(of: "[A-Z]", options: .regularExpression) != nil
        hasSpecialChar = newValue.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        hasNumber = newValue.range(of: "[0-9]", options: .regularExpression) != nil
    }
}

struct RequirementRow: View {
    var isMet: Bool
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark" : "xmark")
                .foregroundColor(isMet ? .green.opacity(0.9) : .red.opacity(0.9))
                .bold()
            
            Text(text)
                .foregroundColor(isMet ? .green.opacity(0.9) : .white.opacity(0.9))
                .bold()
        }
    }
}

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
