//
//  UserCell.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/17.
//

import UIKit

protocol UserCellDelegate: class {
    func didTapFollow(_ cell: UserCell)
    func showActionSheet(_ cell: UserCell)
}

class UserCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var user: User? {
        didSet { configure() }
    }
    
    weak var delegate: UserCellDelegate?
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .lightGray
        return label
    }()
    
    private let sickLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = UIColor(named: "labelTextColor")
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.systemPink.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "backgroundColor")
        
        addSubview(profileImageView)
        profileImageView.setDimensions(width: 48, height: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        profileImageView.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 4, paddingLeft: 12)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel, sickLabel, bioLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        
        addSubview(stack)
        stack.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor,
                          right: rightAnchor,
                          paddingTop: 4, paddingLeft: 8, paddingRight: 12)
        
        addSubview(followButton)
        followButton.anchor(top: stack.bottomAnchor, left: leftAnchor,
                                       right: rightAnchor, paddingTop: 16,
                                       paddingLeft: 24, paddingRight: 24)
        
        addSubview(optionsButton)
        optionsButton.centerY(inView: profileImageView)
        optionsButton.anchor(right: rightAnchor, paddingRight: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .lightGray
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor,
                             right: rightAnchor, height: 0.3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func handleFollowTapped() {
        delegate?.didTapFollow(self)
    }
    
    @objc func showActionSheet() {
        delegate?.showActionSheet(self)
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let user = user else { return }
        let viewModel = UserCellViewModel(user: user)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        
        usernameLabel.text = viewModel.usernameText
        fullnameLabel.text = user.fullname
        sickLabel.text = user.sick
        bioLabel.text = user.bio
        
        followButton.setTitle(viewModel.followButtonText, for: .normal)
        followButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
        followButton.backgroundColor = viewModel.followButtonBackgroundColor
        followButton.isHidden = viewModel.shouldHideButton
        
        optionsButton.isHidden = viewModel.shouldHideButton
    }
}
