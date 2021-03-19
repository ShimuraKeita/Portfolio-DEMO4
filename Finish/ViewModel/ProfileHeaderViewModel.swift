//
//  ProfileHeaderViewModel.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/17.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case posts
    case replies
    case likes
    
    var description: String {
        switch self {
        case .posts: return "投稿"
        case .replies: return "投稿と返信"
        case .likes: return "いいね"
        }
    }
}

struct ProfileHeaderViewModel {
    
    private let user: User
    
    let usernameText: String
    
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "プロフィールを編集"
        }
        
        return user.isFollowed ? "フォロー中" : "フォローする"
    }
    
    var actionButtonBackgroundColor: UIColor {
        if user.isCurrentUser {
            return UIColor(named: "backgroundColor")!
        }
        
        return user.isFollowed ? .systemPink : UIColor(named: "backgroundColor")!
    }
    
    var actionButtonTextColor: UIColor {
        if user.isCurrentUser {
            return .systemPink
        }
        
        return user.isFollowed ? .white : .systemPink
    }

    var shouldHideButton: Bool {
        return user.isCurrentUser
    }
    
    init(user: User) {
        self.user = user
        
        self.usernameText = "@" + user.username
    }
    
    func followersString(valueColor: UIColor, textColor: UIColor) -> NSAttributedString {
        return attributedText(withValue: user.stats?.followers ?? 0, text: "フォロワー",
                              valueColor: valueColor, textColor: textColor)

    }
    
    func followingString(valueColor: UIColor, textColor: UIColor) -> NSAttributedString {
        return attributedText(withValue: user.stats?.following ?? 0, text: "フォロー中",
                              valueColor: valueColor, textColor: textColor)
    }
    
    func postsString(valueColor: UIColor, textColor: UIColor) -> NSAttributedString {
        return attributedText(withValue: user.stats?.posts ?? 0, text: "投稿",
                              valueColor: valueColor, textColor: textColor)
    }
    
    fileprivate func attributedText(withValue value: Int, text: String,
                                    valueColor: UIColor, textColor: UIColor) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)\n",
            attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor: valueColor])
        
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: textColor]))
        return attributedTitle
    }
}
