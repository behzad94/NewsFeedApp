//
//  BookmarksController.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//
import UIKit
import CoreData
import SDWebImage

class BookmarksController: UIViewController {
    
    let sharedView = BookmarksView()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Bookmarks> = {
        let managedContext = DataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Bookmarks>(entityName: "Bookmarks")
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<Bookmarks>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func loadView() {
        super.loadView()
        view = sharedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sharedView.tableView.delegate = self
        sharedView.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        setupNavBar()
        setupNavBarDelButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.sharedView.tableView.reloadData()
        }
    }
    
    private func setupNavBar() {
        navigationItem.title = "bookmarks".uppercased()
    }
    
    func setupNavBarDelButton() {
        let button = UIButton(type: .custom)
        let imageDel = UIImage(named: "delete")
        button.setImage(imageDel, for: .normal)
        button.addTarget(self, action: #selector(delAllTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func delAllTapped() {
        AlertManager.showDeleteAllAlert(vc: self) {
            self.deleteAllData()
        }
    }
    
    func deleteAllData() {
        DataManager.shared.deleteAllData(Bookmarks.self)
        self.navigationItem.setRightBarButton(nil, animated: false)
    }
}

extension BookmarksController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = fetchedResultsController.sections, rows[section].numberOfObjects > 0 {
            setupNavBarDelButton()
            sharedView.tableView.removeEmptyDataMessage()
            return rows[section].numberOfObjects
        } else {
            sharedView.tableView.setEmptyMessage("No Bookmarks, yet")
            self.navigationItem.setRightBarButton(nil, animated: false)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.cellId, for: indexPath) as! BookmarkCell
        let book: Bookmarks = fetchedResultsController.object(at: indexPath)
        cell.titleLabel.text = book.title
        if let img = book.imgUrl {
            cell.photoView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.photoView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: "placeholder"))
        }
        return cell
    }
}

extension BookmarksController: NSFetchedResultsControllerDelegate {
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

extension BookmarksController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac: UIContextualAction, view: UIView, success:(Bool) -> Void) in
            let book: Bookmarks = self.fetchedResultsController.object(at: indexPath)
            if let id = book.id {
                let predicate = NSPredicate(format: "id = %@", id)
                DataManager.shared.deleteDataByPredicate(Bookmarks.self, predicate: predicate)
            }
            success(true)
        })
        deleteAction.image = UIImage(named: "delete")
        deleteAction.backgroundColor = Colors.mainColor
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
