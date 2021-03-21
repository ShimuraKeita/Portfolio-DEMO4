//
//  Constants.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/16.
//

import Firebase

let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_POSTS = DB_REF.child("posts")
let REF_USER_POSTS = DB_REF.child("user-posts")
let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_USER_FOLLOWING = DB_REF.child("user-following")
let REF_POST_REPLIES = DB_REF.child("post-replies")
let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_POST_LIKES = DB_REF.child("post-likes")
let REF_NOTIFICATIONS = DB_REF.child("notifications")
let REF_USER_REPLIES = DB_REF.child("user-replies")
let REF_USER_USERNAMES = DB_REF.child("user-usernames")
let REF_MESSAGES = DB_REF.child("messages")
let REF_USER_MESSAGES = DB_REF.child("user-messages")
let REF_USER_FEED = DB_REF.child("user-feeds")

let KEY_EMAIL = "email"
let KEY_FULLNAME = "fullname"
let KEY_USERNAME = "username"
let KEY_PROFILE_IMAGE_URL = "profileImageUrl"
let KEY_LIKES = "likes"
let KEY_REPOST_COUNT = "reposts"
let KEY_CAPTION = "caption"
let KEY_TIMESTAMP = "timestamp"
let KEY_UID = "uid"
let KEY_TYPE = "type"
let KEY_POST_ID = "postID"
let KEY_FROM_ID = "fromID"
let KEY_TO_ID = "toID"
let KEY_MESSAGE_TEXT = "messageText"
let KEY_MESSAGE_READ = "read"
let KEY_REPOST_USERNAME = "repostUsername"
let KEY_BIO = "bio"


let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_USER_USERNAMES = Firestore.firestore().collection("user-usernames")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")
let COLLECTION_MESSAGES = Firestore.firestore().collection("messages")
let COLLECTION_HASHTAGS = Firestore.firestore().collection("hashtags")
