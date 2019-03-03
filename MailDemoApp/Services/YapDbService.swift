//
//  YapDbService.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 21/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

protocol YapDbServices {
    
    func newConnection() -> YapDatabaseConnection
    
    func addObserver(_ observer: Any, selector: Selector)
}

final class YapDbService {
    
    enum Collections: String {
        
        case folders = "folders"
        case mails = "mails"
        case mailBodies = "mailBodies"
    }
    
    enum Extensions: String {
        
        case folders = "foldersView"
        case mails = "mailsView"
        case relationships = "relationships"
    }
    
    enum Edges: String {
        
        case mailBody = "mailBody"
        case mailFolder = "mailFolder"
    }

    let db: YapDatabase = {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = path.appendingPathComponent("mail.sqlite").path
        let jsonDecoder = JSONDecoder()
        let jsonEncoder = JSONEncoder()
        return YapDatabase(path: dbPath, serializer: { collection, key, object in
            switch collection {
            case Collections.mailBodies.rawValue:
                return try! jsonEncoder.encode(object as! MDMailBody)
            default:
                return YapDatabase.defaultSerializer()(collection, key, object)
            }
        }, deserializer: { collection, key, data in
            switch collection {
            case Collections.mailBodies.rawValue:
                return try! jsonDecoder.decode(MDMailBody.self, from: data)
            default:
                return YapDatabase.defaultDeserializer()(collection, key, data)
            }
        })!
    }()
    
    init() {
        checkFolders()
        registerFoldersView()
        registerMailsView()
        registerRelationships()
    }
}

extension YapDbService: YapDbServices {
    
    func newConnection() -> YapDatabaseConnection {
        return db.newConnection()
    }
    
    func addObserver(_ observer: Any, selector: Selector) {
        let notificationName = Notification.Name(rawValue: YapDatabase.dbModifiedNotification())
        NotificationCenter.default.addObserver(observer, selector: selector, name: notificationName, object: db)
    }
}

extension YapDbService {
    
    private func checkFolders() {
        let connection = db.newConnection()
        connection.readWrite { transaction in
            var keys: [String] = []
            transaction.enumerateKeys(inCollection: YapDbService.Collections.folders.rawValue) { key, _ in
                keys.append(key)
            }
            if keys.count == 0 {
                let inbox = MDFolder(type: .inbox,
                                     title: Localizations.Folders.System.inbox,
                                     order: 1,
                                     allowsMoveMails: true,
                                     isSystem: true)
                transaction.setObject(inbox, forKey: inbox.id, inCollection: YapDbService.Collections.folders.rawValue)
                let outbox = MDFolder(type: .outbox,
                                      title: Localizations.Folders.System.outbox,
                                      order: 2,
                                      allowsMoveMails: false,
                                      isSystem: true)
                transaction.setObject(outbox, forKey: outbox.id, inCollection: YapDbService.Collections.folders.rawValue)
                let drafts = MDFolder(type: .drafts,
                                      title: Localizations.Folders.System.drafts,
                                      order: 3,
                                      allowsMoveMails: false,
                                      isSystem: true)
                transaction.setObject(drafts, forKey: drafts.id, inCollection: YapDbService.Collections.folders.rawValue)
                let spam = MDFolder(type: .spam,
                                    title: Localizations.Folders.System.spam,
                                    order: 4,
                                    allowsMoveMails: true,
                                    isSystem: true)
                transaction.setObject(spam, forKey: spam.id, inCollection: YapDbService.Collections.folders.rawValue)
                let trash = MDFolder(type: .trash,
                                     title: Localizations.Folders.System.trash,
                                     order: 5,
                                     allowsMoveMails: true,
                                     isSystem: true)
                transaction.setObject(trash, forKey: trash.id, inCollection: YapDbService.Collections.folders.rawValue)
            }
        }
    }
    
    private func registerFoldersView() {
        let grouping = YapDatabaseViewGrouping.withRowBlock { transaction, collection, key, object, metadata in
            guard collection == YapDbService.Collections.folders.rawValue, let folder = object as? MDFolder else { return nil }
            return folder.isSystem ? "0" : "1"
        }
        // transaction, group, collection1, key1, object1, meta1, collection2, key2, object2, meta2
        let sorting = YapDatabaseViewSorting.withRowBlock { _, _, _, _, object1, _, _, _, object2, _ in
            guard let folder1 = object1 as? MDFolder, let folder2 = object2 as? MDFolder else { return .orderedSame }
            return folder1.order < folder2.order ? .orderedAscending : .orderedDescending
        }
        let foldersView = YapDatabaseAutoView(grouping: grouping, sorting: sorting)
        db.register(foldersView, withName: YapDbService.Extensions.folders.rawValue)
    }
}

extension YapDbService {
    
    private func registerMailsView() {
        let grouping = YapDatabaseViewGrouping.withRowBlock { transaction, collection, key, object, metadata in
            guard collection == YapDbService.Collections.mails.rawValue, let mail = object as? MDMail else { return nil }
            return mail.folderId
        }
        // transaction, group, collection1, key1, object1, meta1, collection2, key2, object2, meta2
        let sorting = YapDatabaseViewSorting.withRowBlock { _, _, _, _, object1, _, _, _, object2, _ in
            guard let mail1 = object1 as? MDMail, let mail2 = object2 as? MDMail else { return .orderedSame }
            return mail2.date.compare(mail1.date)
        }
        let mailsView = YapDatabaseAutoView(grouping: grouping, sorting: sorting)
        db.register(mailsView, withName: YapDbService.Extensions.mails.rawValue)
    }
}

extension YapDbService {
    
    private func registerRelationships() {
        db.register(YapDatabaseRelationship(), withName: Extensions.relationships.rawValue)
    }
}
