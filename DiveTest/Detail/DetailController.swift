//
//  DetailController.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//

import UIKit
import SDWebImage

class DetailController: UIViewController {
    
    let sharedView = DetailView()
    var feedObj: Feed?
    
    override func loadView() {
        super.loadView()
        view = sharedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        sharedView.browserButton.addTarget(self, action: #selector(openInBrowser), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBookmarkState()
        if let feed = self.feedObj {
            sharedView.titleLabel.text = feed.title
            if let img = feed.imgUrl {
                sharedView.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                sharedView.imageView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: "placeholder"))
            }
        }
    }
    
    @objc func openInBrowser() {
        guard let url = self.feedObj?.link else { return }
        let urlLink = URL(string: url)
        UIApplication.shared.open(urlLink!, options: [:], completionHandler: nil)
    }
    
    private func setupNavBar() {
        navigationItem.title = "details".uppercased()
    }
    
    func getBookmarkState() {
        guard let id = self.feedObj?.postId else { return }
        let predicate = NSPredicate(format: "id = %@", String(describing: id))
        let result = DataManager.shared.fetch(Bookmarks.self, key: nil, ascending: nil, predicate: predicate)
        let img: String
        if !result.isEmpty {
            img = "bookmarksTabbarActive"
        } else {
            img = "bookmarksTabbar"
        }
        let bookmark = UIButton(type: .custom)
        bookmark.setImage(UIImage(named: img), for: .normal)
        bookmark.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        bookmark.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let bookmarkButton = UIBarButtonItem(customView: bookmark)
        navigationItem.rightBarButtonItem = bookmarkButton
    }
    
    @objc func bookmarkTapped() {
        guard let feed = self.feedObj else { return }
        DataManager.shared.storeObjectToBookmarks(feed: feed)
        getBookmarkState()
    }
}
