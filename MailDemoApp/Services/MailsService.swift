//
//  MailsService.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

protocol MailsService {
    
    func bodyFor(mail: MDMail) -> MDMailBody
    
    func composeMail() -> MDMail
    
    func compose(reply: MDMail) -> MDMail
    
    func compose(forward: MDMail, body: String) -> MDMail
    
    func deleteMail(id: String)
    
    func update(mail: MDMail, body: MDMailBody)
    
    func move(mail: MDMail, toFolder folderId: String)
}

final class DefaultMailsService {
    
    private let db: YapDatabase
    
    init(db: YapDatabase) {
        self.db = db
    }
    
    static func store(mail: MDMail, body: MDMailBody, in transaction: YapDatabaseReadWriteTransaction) {
        transaction.setObject(mail, forKey: mail.id, inCollection: YapDbService.Collections.mails.rawValue)
        transaction.setObject(body, forKey: body.id, inCollection: YapDbService.Collections.mailBodies.rawValue)
        let edge = YapDatabaseRelationshipEdge(name: YapDbService.Edges.mailBody.rawValue,
                                               sourceKey: mail.id,
                                               collection: YapDbService.Collections.mails.rawValue,
                                               destinationKey: body.id,
                                               collection: YapDbService.Collections.mailBodies.rawValue,
                                               nodeDeleteRules: .deleteDestinationIfSourceDeleted)
        (transaction.ext(YapDbService.Extensions.relationships.rawValue) as! YapDatabaseRelationshipTransaction).add(edge)
    }
    
    private func store(mail: MDMail, body: MDMailBody) {
        db.newConnection().readWrite { transaction in
            DefaultMailsService.store(mail: mail, body: body, in: transaction)
        }
    }
}

extension DefaultMailsService: MailsService {
    
    func bodyFor(mail: MDMail) -> MDMailBody {
        var body: MDMailBody!
        db.newConnection().read { transaction in
            body = transaction.object(forKey: mail.id, inCollection: YapDbService.Collections.mailBodies.rawValue) as? MDMailBody
        }
        return body
    }
    
    func composeMail() -> MDMail {
        let mail = MDMail(sender: "azat.almeev@gmx.de", isIncome: false, folderId: FolderType.drafts.id)
        store(mail: mail, body: MDMailBody(id: mail.id, body: ""))
        return mail
    }
    
    func compose(reply: MDMail) -> MDMail {
        let recipient = reply.isIncome ? reply.sender : reply.recipient
        let folderId = FolderType.drafts.id
        let mail = MDMail(sender: "azat.almeev@gmx.de", subject: reply.subject, recipient: recipient, isIncome: false, folderId: folderId)
        store(mail: mail, body: MDMailBody(id: mail.id, body: ""))
        return mail
    }
    
    func compose(forward: MDMail, body: String) -> MDMail {
        let mail = MDMail(sender: "azat.almeev@gmx.de", subject: forward.subject, isIncome: false, folderId: FolderType.drafts.id)
        store(mail: mail, body: MDMailBody(id: mail.id, body: body))
        return mail
    }
    
    func move(mail: MDMail, toFolder folderId: String) {
        db.newConnection().readWrite { transaction in
            self.move(mail: mail, toFolder: folderId, transaction: transaction)
        }
    }
    
    func move(mail: MDMail, toFolder folderId: String, transaction: YapDatabaseReadWriteTransaction) {
        let updated = mail.updated(folderId: folderId)
        transaction.setObject(updated, forKey: updated.id, inCollection: YapDbService.Collections.mails.rawValue)
    }

    func deleteMail(id: String) {
        db.newConnection().readWrite { transaction in
            if let mail = transaction.object(forKey: id, inCollection: YapDbService.Collections.mails.rawValue) as? MDMail {
                switch mail.folderId {
                case FolderType.drafts.id, FolderType.trash.id, FolderType.spam.id:
                    transaction.removeObject(forKey: mail.id, inCollection: YapDbService.Collections.mails.rawValue)
                default:
                    self.move(mail: mail, toFolder: FolderType.trash.id, transaction: transaction)
                }
            }
        }
    }
    
    func update(mail: MDMail, body: MDMailBody) {
        db.newConnection().readWrite { transaction in
            transaction.setObject(mail, forKey: mail.id, inCollection: YapDbService.Collections.mails.rawValue)
            transaction.setObject(body, forKey: body.id, inCollection: YapDbService.Collections.mailBodies.rawValue)
        }
    }
}
