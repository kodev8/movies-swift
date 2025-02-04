//
//  SecurityHelper.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import Foundation
import CryptoKit


struct SecurityHelper {
    static func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
   
    static func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
   
    static func formatName(_ name: String) -> String {
        return name.capitalized
    }
}



