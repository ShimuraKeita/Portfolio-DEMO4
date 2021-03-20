//
//  PostController.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/17.
//

import UIKit

private let reuseIdentifier = "PostCell"
private let headerIdentifier = "PostHeader"
class PostController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var post: Post
    private var actionSheetLauncher: ActionSheetLauncher!
    private var replies = [Post]() {
        didSet { collectionView.reloadData() }
    }
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = UIColor(named: "buttonTitleColor")
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureNavigationBar()
        fetchReplies()
        checkIfUserIsFollowed()
    }
    
    //MARK: - Selectors
    
    @objc func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }

    //MARK: - API
    
    func fetchReplies() {
        PostService.shared.fetchReplies(forPost: post) { replies in
            self.replies = replies
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: post.user.uid) { isFollowed in
            self.post.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }

    //MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = UIColor(named: "backgroundColor")
        
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(PostHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    fileprivate func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
}

//MARK: - UICollectionViewDataSource

extension PostController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCell
        cell.delegate = self
        cell.post = replies[indexPath.row]
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension PostController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! PostHeader
        header.post = post
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = PostController(post: replies[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}


//MARK: - UICollectionViewDelegateFlowLayout

extension PostController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = PostViewModel(post: post)
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: height + 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

//MARK: - PostHeaderDelegate

extension PostController: PostHeaderDelegate {
    func handleProfileImageTapped(_ header: PostHeader) {
        let controller = ProfileController(user: post.user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ header: PostHeader) {
        let controller = UploadPostController(user: post.user, config: .reply(post))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ header: PostHeader) {
        guard let post = header.post else { return }
        
        PostService.shared.likePost(post: post) { (err, ref) in
            header.post?.didLike.toggle()
            let likes = post.didLike ? post.likes - 1 : post.likes + 1
            header.post?.likes = likes
            
            guard !post.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: post.user,
                                                          type: .like,
                                                          postID: post.postID)
        }
    }
    
    func showActionSheet(_ header: PostHeader) {
        if post.user.isCurrentUser {
            showActionSheet(forUser: post.user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: post.user.uid) { isFollowed in
                var user = self.post.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
}

//MARK: - PostCellDelegate

extension PostController: PostCellDelegate {
    func handleProfileImageTapped(_ cell: PostCell) {
        guard let user = cell.post?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }

    func handleReplyTapped(_ cell: PostCell) {
        guard let post = cell.post else { return }
        let controller = UploadPostController(user: post.user, config: .reply(post))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ cell: PostCell) {
        guard let post = cell.post else { return }
        
        PostService.shared.likeReply(post: post) { (err, ref) in
            cell.post?.didLike.toggle()
            let likes = post.didLike ? post.likes - 1 : post.likes + 1
            cell.post?.likes = likes
            
            // only upload notification if tweet is being liked
            guard !post.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: post.user,
                                                          type: .like,
                                                          postID: post.postID)
        }
    }
    
    func showActionSheet(_ cell: PostCell) {
        guard let post = cell.post else { return }
        if post.user.isCurrentUser {
            showActionSheet(forUser: post.user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: post.user.uid) { isFollowed in
                var user = post.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
}

//MARK: - ActionSheetLauncherDelegate

extension PostController: ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                self.post.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.shared.uploadNotification(toUser: self.post.user, type: .follow)
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                self.post.user.isFollowed = false
                self.collectionView.reloadData()
            }
        case .report:
            print("DEBUG: Report tweet")
        case .delete:
            print("DEBUG: Delete tweet..")
        case .block(_):
            print("DEBUG: Delete tweet..")
        case .unblock(_):
            print("DEBUG: Delete tweet..")
        }
    }
}
