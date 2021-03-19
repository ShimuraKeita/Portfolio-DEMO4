//
//  EditProfileController.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/19.
//

import UIKit

private let reuseIdentifier = "EditProfileCell"

class EditProfileController: UITableViewController {
    
    //MARK: - Properties
    
    private let user: User
    private lazy var headerView = EditProfileHeader(user: user)
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPink
        button.setTitle("更新", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
    }
    
    //MARK: - Selectors
    
    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    //MARK: - API

    //MARK: - Helpers
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "プロフィール編集"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "buttonTitleColor")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
    func configureTableView() {
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        headerView.delegate = self
        
        tableView.tableFooterView = UIView()
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

//MARK: - UITableViewDataSource

extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell }
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        cell.contentView.isUserInteractionEnabled = false
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return option == .bio ? 300 : 48
    }
}

//MARK: - EditProfileHeaderDelegate

extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        
    }
}
