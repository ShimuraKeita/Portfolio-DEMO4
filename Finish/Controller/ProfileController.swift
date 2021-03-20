//
//  ProfileController.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/16.
//

import UIKit

private let reuseIdentifier = "PostCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var user: User
    private var actionSheetLauncher: ActionSheetLauncher!
    
    private var selectedFilter: ProfileFilterOptions = .posts {
        didSet { collectionView.reloadData() }
    }
    
    private var posts = [Post]()
    private var likedPosts = [Post]()
    private var replies = [Post]()
    
    private var currentDataSource: [Post] {
        switch selectedFilter {
        case .posts: return posts
        case .replies: return replies
        case .likes: return likedPosts
        }
    }
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = UIColor(named: "buttonTitleColor")
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureNavigationBar()
        fetchPosts()
        fetchLikedPosts()
        fetchReplies()
        checkIfUserIsFollowed()
        fetchUserStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }

    //MARK: - Selectors
    
    @objc func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API
    
    func fetchPosts() {
        PostService.shared.fetchPosts(forUser: user) { (posts) in
            self.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedPosts()
            self.collectionView.reloadData()
        }
    }
    
    func fetchLikedPosts() {
        PostService.shared.fetchLikes(forUser: user) { posts in
            self.likedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedPosts()
            self.collectionView.reloadData()
        }
    }
    
    func fetchReplies() {
        PostService.shared.fetchReplies(forUser: user) { (posts) in
            self.replies = posts.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedPosts()
            self.collectionView.reloadData()
        }
    }
    
    func checkIfUserLikedPosts() {
        self.posts.forEach { post in
            PostService.shared.checkIfUserLikedPost(post) { didLike in
                guard didLike == true else { return }
                
                if let index = self.posts.firstIndex(where: { $0.postID == post.postID }) {
                    self.posts[index].didLike = true
                }
            }
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }

    //MARK: - Helpers

    func configureCollectionView() {
        collectionView.backgroundColor = UIColor(named: "backgroundColor")
        navigationItem.title = "プロフィール"
        
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
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

//MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCell
        cell.delegate = self
        cell.post = currentDataSource[indexPath.row]
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = PostController(post: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = PostViewModel(post: currentDataSource[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: height + 72)
    }
}

extension ProfileController: ProfileHeaderDelegate {
    func handleEditProfileFollow(_ header: ProfileHeader) {
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
//            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
                        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (ref, err) in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
            }
        }
    }
    
    func showActionSheet(_ header: ProfileHeader) {
        if user.isCurrentUser {
            showActionSheet(forUser: user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
                var user = self.user
                user.isFollowed = isFollowed
                self.showActionSheet(forUser: user)
            }
        }
    }
    
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
}

// MARK: - ActionSheetLauncherDelegate

extension ProfileController: ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                self.user.isFollowed = false
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

//MARK: - PostCellDelegate

extension ProfileController: PostCellDelegate {
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
        
        PostService.shared.likePost(post: post) { (err, ref) in
            cell.post?.didLike.toggle()
            let likes = post.didLike ? post.likes - 1 : post.likes + 1
            cell.post?.likes = likes
            
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
