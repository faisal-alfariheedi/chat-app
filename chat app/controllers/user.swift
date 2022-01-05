//
//  user.swift
//  chat app
//
//  Created by faisal on 01/06/1443 AH.
//

import Foundation
import Firebase

struct myuser{
    static var fireuser:Firebase.User?
    static var userr:userr?
    
}
struct userr{
    let id:String
    let email:String
    let first:String
    let last:String
    var firemailsafe:String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var picurl:String?
}
//struct ChatAppUser {
//    let firstName: String
//    let lastName: String
//    let emailAddress: String
//    //let profilePictureUrl: String
//    // create a computed property safe email
//    var safeEmail: String {
//        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
//        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
//        return safeEmail
//    }
//}
