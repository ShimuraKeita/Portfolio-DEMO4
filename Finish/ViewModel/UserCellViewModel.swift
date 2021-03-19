//
//  UserCellViewModel.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/17.
//

import UIKit

struct UserCellViewModel {
    
    private let user: User
    
    let usernameText: String

    var followButtonText: String {
        return user.isFollowed ? "フォロー中" : "フォローする"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isFollowed ? .systemPink : UIColor(named: "backgroundColor")!
    }
    
    var followButtonTextColor: UIColor {
        return user.isFollowed ? .white : .systemPink
    }
    
    var shouldHideButton: Bool {
        return user.isCurrentUser
    }
    
    init(user: User) {
        self.user = user
        
        self.usernameText = "@" + user.username
    }
    
    // MARK: - Helpers
    
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = user.bio
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
