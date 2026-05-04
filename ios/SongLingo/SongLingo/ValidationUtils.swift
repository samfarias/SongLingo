//
//  ValidationUtils.swift
//  SongLingo
//
//  Created by Derek Huang on 5/4/26.
//

import Foundation

struct ValidationUtils {
    
    static func isNotEmpty(email: String, password: String) -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    static func checkPasswordRequirements(password: String) -> (minLen: Bool, letter: Bool, upper: Bool, special: Bool, number: Bool) {
        return (
            minLen: password.count >= 8,
            letter: password.range(of: "[A-Za-z]", options: .regularExpression) != nil,
            upper: password.range(of: "[A-Z]", options: .regularExpression) != nil,
            special: password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil,
            number: password.range(of: "[0-9]", options: .regularExpression) != nil
        )
    }
}
