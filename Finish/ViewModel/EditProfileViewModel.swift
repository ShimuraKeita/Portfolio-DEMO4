//
//  EditProfileViewModel.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/19.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case sick
    case bio
    
    var description: String {
        switch self {
        case .username: return "ユーザーネーム"
        case .fullname: return "名前"
        case .sick: return "病名"
        case .bio: return "プロフィール文"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .username: return user.username
        case .fullname: return user.fullname
        case .sick: return user.sick
        case .bio: return user.bio
        }
    }
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
