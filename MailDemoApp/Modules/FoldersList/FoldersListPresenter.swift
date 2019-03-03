//
//  FoldersListPresenter.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 12/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

final class FoldersListPresenter {
    
    weak var view: FoldersListViewInput?

    private let dbService: YapDbServices
    private let foldersService: FoldersService

    init(dbService: YapDbServices, foldersService: FoldersService) {
        self.dbService = dbService
        self.foldersService = foldersService
    }

    private lazy var dbConnection: YapDatabaseConnection = {
        return dbService.newConnection()
    }()

    private lazy var mapping: YapDatabaseViewMappings = {
        return YapDatabaseViewMappings(groupFilterBlock: { _, _ in true }, sortBlock: { key1, key2, transaction in
            return key1.compare(key2)
        }, view: YapDbService.Extensions.folders.rawValue)
    }()

    @objc func dbDidChangeNotification(_ notification: Notification) {
        let notifications = dbConnection.beginLongLivedReadTransaction()
        if (dbConnection.ext(YapDbService.Extensions.folders.rawValue) as! YapDatabaseViewConnection).hasChanges(for: notifications) {
            dbConnection.read(mapping.update(with:))
        }
        view?.updateUI()
    }
}

extension FoldersListPresenter: FoldersListViewOutput {

    var groupsCount: Int {
        return Int(mapping.numberOfSections())
    }
    
    func title(at index: Int) -> String? {
        guard groupsCount > 1 else { return nil }
        return index == 0 ? Localizations.Folders.systemFolders : Localizations.Folders.customFolders
    }
    
    func isRowEditable(at indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func foldersCount(inGroup: Int) -> Int {
        return Int(mapping.numberOfItems(inSection: UInt(inGroup)))
    }
    
    subscript (indexPath: IndexPath) -> MDFolder {
        var object: MDFolder!
        dbConnection.read { transaction in
            let ext = transaction.ext(YapDbService.Extensions.folders.rawValue) as! YapDatabaseViewTransaction
            object = ext.object(at: indexPath, with: self.mapping) as? MDFolder
        }
        return object
    }

    func viewIsReady() {
        dbConnection.beginLongLivedReadTransaction()
        dbConnection.read(mapping.update(with:))
        dbService.addObserver(self, selector: #selector(dbDidChangeNotification(_:)))
    }
    
    func handleAddFolder(name: String) {
        foldersService.createCustomFolder(name: name)
    }
    
    func handleDeletion(folderId: String) {
        foldersService.deleteFolder(id: folderId)
    }
}
