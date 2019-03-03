//
//  FoldersService.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

protocol FoldersService {
    
    func getAllFolders() -> [MDFolder]
    
    func createCustomFolder(name: String)
    
    func deleteFolder(id: String)
}

extension FoldersService {
    
    func getCustomFolders() -> [MDFolder] {
        return getAllFolders().filter { !$0.isSystem }
    }
    
    func hasCustomFolders() -> Bool {
        return getCustomFolders().count > 0
    }
}

final class DefaultFoldersService {

    private let db: YapDatabase
    
    init(db: YapDatabase) {
        self.db = db
    }
}

extension DefaultFoldersService: FoldersService {
    
    func getAllFolders() -> [MDFolder] {
        var result: [MDFolder] = []
        db.newConnection().read { transaction in
            transaction.enumerateRows(inCollection: YapDbService.Collections.folders.rawValue) { key, object, _, _ in
                if let folder = object as? MDFolder {
                    result.append(folder)
                }
            }
        }
        return result
    }
    
    func createCustomFolder(name: String) {
        let nextOrder = getCustomFolders().reduce(0) { result, folder in
            max(result, folder.order)
        }
        let folder = MDFolder(title: name, order: nextOrder, allowsMoveMails: true, isSystem: false)
        db.newConnection().readWrite { transaction in
            transaction.setObject(folder, forKey: folder.id, inCollection: YapDbService.Collections.folders.rawValue)
        }
    }
    
    func deleteFolder(id: String) {
        db.newConnection().readWrite { transaction in
            let collection = YapDbService.Collections.folders.rawValue
            if let folder = transaction.object(forKey: id, inCollection: collection) as? MDFolder, !folder.isSystem {
                transaction.removeObject(forKey: folder.id, inCollection: YapDbService.Collections.folders.rawValue)
            }
        }
    }
}
