//
//  NewsTableController.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class NewsController: UIViewController {
    
    let sharedView = NewsView()
    private var rssItems: [RSSItem]?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Feed> = {
        let managedContext = DataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Feed>(entityName: "Feed")
        let sortDescriptor = NSSortDescriptor(key: "pubdate", ascending: false)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<Feed>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func loadView() {
        super.loadView()
        view = sharedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        sharedView.tableView.delegate = self
        sharedView.tableView.dataSource = self
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.sharedView.tableView.reloadData()
        }
    }
    
    private func setupNavBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = Colors.mainColor
        navigationItem.title = "feed".uppercased()
    }
    
    private func getData() {
        DataManager.shared.deleteDataByPredicate(Feed.self, predicate: nil)
        let feedParser = FeedParser()
        feedParser.parseFeed(url: firstURL) { rss in
            rss.forEach {
                self.rssItems?.append($0)
            }
        }
        
        //delay. only for test purpose!
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            feedParser.parseFeed(url: secondURL) { rss in
                rss.forEach {
                    self.rssItems?.append($0)
                }
            }
        }
    }
}

extension NewsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = fetchedResultsController.sections, rows.count > 0 {
            return rows[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.cellId, for: indexPath) as! NewsCell
        let feed: Feed = fetchedResultsController.object(at: indexPath)
        cell.titleLabel.text = feed.title
        
        cell.publishDateLabel.text = feed.pubdate?.StringDateToMediumDate()
        if let img = feed.imgUrl {
            cell.photoView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.photoView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: "placeholder"))
        }
        if let feedId = feed.postId {
            let predicate = NSPredicate(format: "id = %@", feedId)
            let result = DataManager.shared.fetch(Bookmarks.self, key: nil, ascending: nil, predicate: predicate)
            if !result.isEmpty && result.first?.id == feedId {
                cell.iconView.isHidden = false
            } else {
                cell.iconView.isHidden = true
            }
        }
        return cell
    }
}

extension NewsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let moreAction = UIContextualAction(style: .normal, title:  "", handler: { (ac: UIContextualAction, view: UIView, success:(Bool) -> Void) in
            let feed: Feed = self.fetchedResultsController.object(at: indexPath)
            guard let link = feed.link else { return }
            let url = URL(string: link)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            success(true)
        })
        moreAction.image = UIImage(named: "more")
        moreAction.backgroundColor = Colors.secondaryColor
        return UISwipeActionsConfiguration(actions: [moreAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed: Feed = self.fetchedResultsController.object(at: indexPath)
        let detailController = DetailController()
        detailController.feedObj = feed
        self.navigationController?.pushViewController(detailController, animated: true)
    }
}

extension NewsController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sharedView.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            sharedView.tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
        case .delete:
            sharedView.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .none)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            sharedView.tableView.insertRows(at: [newIndexPath!], with: .none)
        case .delete:
            sharedView.tableView.deleteRows(at: [indexPath!], with: .none)
        case .update:
            sharedView.tableView.reloadRows(at: [indexPath!], with: .none)
        case .move:
            sharedView.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sharedView.tableView.endUpdates()
    }
}
