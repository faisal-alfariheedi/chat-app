//
//  DBmanager.swift
//  chat app
//
//  Created by faisal on 01/06/1443 AH.
//

import Foundation
import Firebase
import FacebookLogin

final class DBmanger {
    
    static let shared = DBmanger()
    
    // reference the database below
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    // create a simple write function
    
    public func safeEmail(email:String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    public func userDoExists(with email:String, completion: @escaping ((Bool) -> Void)) {
            // will return true if the user email does not exist
            
            // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
            // let's observe a single event (query the database once)
            
            var safeEmail = email.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            
            database.child("users").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
                // snapshot has a value property that can be optional if it doesn't exist
                
                guard snapshot.value as? String != nil else {
                    // otherwise... let's create the account
                    completion(false)
                    return
                }
                
                // if we are able to do this, that means the email exists already!
                
                completion(true) // the caller knows the email exists already
            }
        }
    func setuser(with email:String){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child("users").child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            let value = snapshot.value as! NSDictionary
            myuser.userr = userr(id: myuser.fireuser!.uid, email: myuser.fireuser!.email!, first: value["first_name"] as! String, last: value["last_name"] as! String , picurl: value["picurl"] as! String)
            
          }) { error in
            print(error.localizedDescription)
          }
    }
    func fbsetuser(with profile: Profile){
        myuser.userr = userr(id: profile.userID, email: profile.email!, first: profile.firstName!, last: profile.lastName!, picurl: profile.imageURL!.description)
    }
        
        /// Insert new user to database
    public func insertUser(with temp:Firebase.User,img:Data,first:String,last:String){
        uploadProfilePicture(with: img, fileName: "\(temp.uid) profile", completion: {Result in
            switch Result{
                case .success(let url):
                    myuser.userr = userr(id: temp.uid, email: temp.email!, first: first, last: last, picurl:url)
                    self.database.child("users").child(myuser.userr!.firemailsafe).setValue(["first_name":myuser.userr!.first,"last_name":myuser.userr!.last,"picurl":myuser.userr!.picurl])
                
                case .failure(let err): print(err)
            }
        })
        }
    public func fbinsertUser(with id:String,email:String,first:String,last:String,img:Data){
        uploadProfilePicture(with: img, fileName: "\(id) profile", completion: {Result in
            switch Result{
                case .success(let url):
                    myuser.userr = userr(id: id, email: email, first: first, last: last, picurl:url)
                        self.database.child("users").child(myuser.userr!.firemailsafe).setValue(["first_name":myuser.userr!.first,"last_name":myuser.userr!.last,"picurl":myuser.userr!.picurl])
                
                case .failure(let err): print(err)
            }
        })
        
        }
    
    
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void // type alias makes things cleaner
        
        /// Uploads picture to firebase storage and returns completion with url string to download
        public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
            // return a string of the download URL
            // if we succeed, return a string, otherwise return error
            
            storage.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
                guard error == nil else {
                    // failed
                    print("failed to upload data to firebase for picture")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                
                self.storage.child("images/\(fileName)").downloadURL { url, error in
                    guard let url = url else {
                        print("Failed to get download url")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    
                    let urlString = url.absoluteString
                    
                    print("download url returned: \(urlString)")
                    
                    completion(.success(urlString))
                }
            }
            
        }
        
        public func downloadURL(for path: String,completion: @escaping (Result<URL, Error>) -> Void) {
            let reference = storage.child(path)
            
            // whole closure is escaping
            // when you call the completion down below, it can escape the asynchronous execution block that firebase provides
            
            reference.downloadURL { url, error in
                guard let url = url, error == nil else {
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                completion(.success(url))
            }
        }
        
        public enum StorageErrors: Error {
            case failedToUpload
            case failedToGetDownloadUrl
        }
    
}
