//
//  PostViewModel.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/16.
//

import UIKit

struct PostViewModel {
    
    // MARK: - Properties
    
    let post: Post
    let user: User
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: post.timestamp, to: now) ?? "2m"
    }
    
    var usernameText: String {
        return "@\(user.username)"
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a · yyyy/MM/dd"
        return formatter.string(from: post.timestamp)
    }
    
    var likesAttributedString: NSAttributedString? {
        return attributedText(withValue: post.likes, text: "いいね")
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname,
                                              attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        title.append(NSAttributedString(string: " @\(user.username)",
            attributes: [.font: UIFont.systemFont(ofSize: 14),
                         .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: " \(user.sick)",
            attributes: [.font: UIFont.systemFont(ofSize: 14),
                         .foregroundColor: UIColor.lightGray]))
        
        title.append(NSAttributedString(string: " · \(timestamp)",
        attributes: [.font: UIFont.systemFont(ofSize: 14),
                     .foregroundColor: UIColor.lightGray]))
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? .red : UIColor(named: "labelTextColor") ?? .black
    }
    
    var likeButtonImage: UIImage {
        let imageName = post.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)!
    }
    
    var shouldHideReplyLabel: Bool {
        return !post.isReply
    }
    
    var replyText: String? {
        guard let replyingToUsername = post.replyingTo else { return nil }
        return "返信先: @\(replyingToUsername)さん"
    }
    
    // MARK: - Lifecycle
    
    init(post: Post) {
        self.post = post
        self.user = post.user
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
                                                        attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
    
    // MARK: - Helpers
    
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = post.caption
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
