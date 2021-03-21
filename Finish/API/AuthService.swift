//
//  AuthService.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/16.
//

import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        let email = credentials.email
        let password = credentials.password
        let username = credentials.username
        let fullname = credentials.fullname
        let profileImage = credentials.profileImage
        
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print("DEBUG: Error is \(error.localizedDescription)")
                        return
                    }
                                        
                    guard let uid = result?.user.uid else { return }
                    
                    let data = ["email": email,
                                "username": username,
                                "fullname": fullname,
                                "uid": uid,
                                "profileImageUrl": profileImageUrl]
                    
                    COLLECTION_USERS.document(uid).setData(data, completion: completion)
                    
//                    REF_USERS.child(uid).updateChildValues(values) { (err, ref) in
//                        REF_USER_USERNAMES.updateChildValues([username: uid], withCompletionBlock: completion)
//                    }
                }
            }
        }
    }
    
    func sendPasswordReset(withEmail email: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().languageCode = "ja_JP"
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
}
