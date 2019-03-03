//
//  MailsListPresenter.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 21/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

final class MailsListPresenter {
    
    weak var view: MailsListViewInput?

    private let dbService: YapDbServices
    private let mailsService: MailsService
    private let folder: MDFolder
    
    init(dbService: YapDbServices, mailsService: MailsService, folder: MDFolder) {
        self.dbService = dbService
        self.mailsService = mailsService
        self.folder = folder
    }
    
    private lazy var dbConnection: YapDatabaseConnection = {
        return dbService.newConnection()
    }()
    
    private lazy var mapping: YapDatabaseViewMappings = {
        return YapDatabaseViewMappings(groupFilterBlock: { group, transaction in
            group == self.folder.id
        }, sortBlock: { _, _, _ in .orderedSame }, view: YapDbService.Extensions.mails.rawValue)
    }()
    
    @objc func dbDidChangeNotification(_ notification: Notification) {
        let notifications = dbConnection.beginLongLivedReadTransaction()
        if (dbConnection.ext(YapDbService.Extensions.mails.rawValue) as! YapDatabaseViewConnection).hasChanges(for: notifications) {
            dbConnection.read(mapping.update(with:))
        }
        view?.updateUI()
    }
}

extension MailsListPresenter: MailsListViewOutput {
    
    var areMailsReadonly: Bool {
        return folder.isReadOnly
    }
    
    var showsMailIcons: Bool {
        return folder.folderType == .trash
    }
    
    var mailsCount: Int {
        return Int(mapping.numberOfItems(inSection: 0))
    }
    
    subscript (index: Int) -> MDMail {
        var object: MDMail!
        dbConnection.read { transaction in
            let ext = transaction.ext(YapDbService.Extensions.mails.rawValue) as! YapDatabaseViewTransaction
            object = ext.object(atRow: UInt(index), inSection: 0, with: self.mapping) as? MDMail
        }
        return object
    }
    
    func viewIsReady() {
        view?.title = folder.title
        dbConnection.beginLongLivedReadTransaction()
        dbConnection.read(mapping.update(with:))
        dbService.addObserver(self, selector: #selector(dbDidChangeNotification(_:)))
        if folder.folderType == .inbox {
            view?.setupComposeButton()
        }
    }
    
    func handleDeletion(mailId: String) {
        mailsService.deleteMail(id: mailId)
    }
    
    func handleComposeMail() -> MDMail {
        return mailsService.composeMail()
    }
}
