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
        case .fullname: return "名前"
        case .username: return "ユーザーネーム"
        case .sick: return "病名"
        case .bio: return "自己紹介"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String {
        switch option {
        case .fullname: return user.fullname
        case .username: return user.username
        case .sick: return user.sick
        case .bio: return user.bio
        }
    }
    
    var optionPlaceholderText: String {
        switch option {
        case .fullname: return "名前を追加"
        case .username: return "ユーザーネームを追加"
        case .sick: return "病名を追加"
        case .bio: return "プロフィールに自己紹介を追加"
        }
    }
    
    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != ""
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
