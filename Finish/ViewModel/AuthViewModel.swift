//
//  AuthViewModel.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/16.
//

import Foundation

protocol AuthViewModel {
    var formIsvalid: Bool { get }
}

struct LoginViewModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false &&
            password?.isEmpty == false 
    }
}

struct RegistrationViewModel {
    var email: String?
    var password: String?
    var repeatPassword: String?
    var fullname: String?
    var username: String?

    var formIsValid: Bool {
        return email?.isEmpty == false &&
            password?.isEmpty == false &&
            repeatPassword?.isEmpty == false &&
            fullname?.isEmpty == false &&
            username?.isEmpty == false
    }
}

struct ForgotPasswordViewModel {
    var email: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false
    }
}

struct AccountDeletionViewModel {
    var password: String?
    
    var formIsValid: Bool {
        return password?.isEmpty == false
    }
}

struct ResetPasswordViewModel {
    var currentPassword: String?
    var newPassword: String?
    
    var formIsValid: Bool {
        return currentPassword?.isEmpty == false
            && newPassword?.isEmpty == false
    }
}
