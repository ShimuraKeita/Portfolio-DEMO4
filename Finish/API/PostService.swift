//
//  PostService.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/16.
//

import Firebase

struct PostService {
    static let shared = PostService()
    
    func uploadPost(caption: String, type: UploadPostConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var values = [KEY_CAPTION: caption,
                      KEY_TIMESTAMP: Int(NSDate().timeIntervalSince1970),
                      KEY_LIKES: 0,
                      KEY_UID: uid] as [String : Any]
                
        switch type {
        case .reply(let post):
            REF_POST_REPLIES.child(post.postID).childByAutoId().updateChildValues(values) { (err, ref) in
                guard let replyKey = ref.key else { return }
                REF_USER_REPLIES.child(uid).updateChildValues([post.postID: replyKey], withCompletionBlock: completion)
            }
        case .post:
            REF_POSTS.childByAutoId().updateChildValues(values) { (err, ref) in
                guard let key = ref.key else { return }
                REF_USER_POSTS.child(uid).updateChildValues([key: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func fetchPosts(completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        guard let currentuid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentuid).observe(.childAdded) { (snapshot) in
            let followingUid = snapshot.key
            print("followingUid\(followingUid)")
            
            REF_USER_POSTS.child(followingUid).observe(.childAdded) { (snapshot) in
                let postID = snapshot.key
                print("postID\(postID)")
                
                self.fetchPost(withPostID: snapshot.key) { post in
                    posts.append(post)
                    completion(posts)
                }
            }
        }
        
        REF_USER_POSTS.child(currentuid).observe(.childAdded) { (snapshot) in
            let postID = snapshot.key
            print("postID\(postID)")
            
            self.fetchPost(withPostID: snapshot.key) { post in
                posts.append(post)
                completion(posts)
            }
        }
    }
    
    func fetchPosts(forUser user: User, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        REF_USER_POSTS.child(user.uid).observe(.childAdded) { (snapshot) in
            let postID = snapshot.key
            
            REF_POSTS.child(postID).observeSingleEvent(of: .value) { (snapshot) in
                self.fetchPost(withPostID: snapshot.key) { post in
                    posts.append(post)
                    completion(posts)
                }
            }
        }
    }
    
    func fetchPost(withPostID postID: String, completion: @escaping(Post) -> Void) {
        REF_POSTS.child(postID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { (user) in
                let post = Post(user: user, postID: postID, dictionary: dictionary)
                completion(post)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Post]) -> Void) {
        var replies = [Post]()
        
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { (snapshot) in
            let postKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            REF_POST_REPLIES.child(postKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                let replyID = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = Post(user: user, postID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    func fetchReplies(forPost post: Post, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        REF_POST_REPLIES.child(post.postID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let postID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let post = Post(user: user, postID: postID, dictionary: dictionary)
                posts.append(post)
                completion(posts)
            }
        }
    }
    
    func fetchLikes(forUser user: User, completion: @escaping([Post]) -> Void) {
        var posts = [Post]()
        
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            let postID = snapshot.key
            self.fetchPost(withPostID: postID) { likedPost in
                var post = likedPost
                post.didLike = true
                
                posts.append(post)
                completion(posts)
            }
        }
    }
    
    func likePost(post: Post, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = post.didLike ? post.likes - 1 : post.likes + 1
        REF_POSTS.child(post.postID).child("likes").setValue(likes)
        
        if !post.didLike {
            REF_USER_LIKES.child(uid).updateChildValues([post.postID: 1]) { (err, ref) in
                REF_POST_LIKES.child(post.postID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        } else {
            guard post.likes > 0 else { return }
            REF_USER_LIKES.child(uid).child(post.postID).removeValue { (err, ref) in
                REF_POST_LIKES.child(post.postID).removeValue(completionBlock: completion)
            }
        }
    }
    
    func likeReply(post: Post, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = post.didLike ? post.likes - 1 : post.likes + 1
        REF_POSTS.child(post.postID).child("likes").setValue(likes)
        
        if !post.didLike {
            REF_USER_LIKES.child(uid).updateChildValues([post.postID: 1]) { (err, ref) in
                REF_POST_LIKES.child(post.postID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        } else {
            guard post.likes > 0 else { return }
            REF_USER_LIKES.child(uid).child(post.postID).removeValue { (err, ref) in
                REF_POST_LIKES.child(post.postID).removeValue(completionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedPost(_ post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(uid).child(post.postID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
