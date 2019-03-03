//
//  MDMail.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 22.02.19.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

class MDMail: NSObject {
    
    let id: String
    let date: Date
    let sender: String
    let subject: String?
    let recipient: String?
    let isIncome: Bool
    let folderId: String
    
    var readyToSend: Bool {
        return !isIncome && folderId == FolderType.drafts.id && subject?.isEmpty == false && recipient?.isEmpty == false
    }
    
    private init(id: String, date: Date, sender: String, subject: String?, recipient: String?, isIncome: Bool, folderId: String) {
        self.id = id
        self.date = date
        self.sender = sender
        self.subject = subject
        self.recipient = recipient
        self.isIncome = isIncome
        self.folderId = folderId
        super.init()
    }
    
    convenience init(sender: String, subject: String? = nil, recipient: String? = nil, isIncome: Bool, folderId: String) {
        self.init(id: NSUUID().uuidString,
                  date: Date(),
                  sender: sender,
                  subject: subject,
                  recipient: recipient,
                  isIncome: isIncome,
                  folderId: folderId)
    }

    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
        self.sender = aDecoder.decodeObject(forKey: "sender") as! String
        self.subject = aDecoder.decodeObject(forKey: "subject") as? String
        self.recipient = aDecoder.decodeObject(forKey: "recipient") as? String
        self.isIncome = aDecoder.decodeBool(forKey: "isIncome")
        self.folderId = aDecoder.decodeObject(forKey: "folderId") as! String
    }
    
    func updated(folderId: String) -> MDMail {
        return MDMail(id: id, date: date, sender: sender, subject: subject, recipient: recipient, isIncome: isIncome, folderId: folderId)
    }
    
    func updated(recipient: String?, subject: String?) -> MDMail {
        return MDMail(id: id, date: Date(), sender: sender, subject: subject, recipient: recipient, isIncome: isIncome, folderId: folderId)
    }
}

extension MDMail: NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(sender, forKey: "sender")
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(recipient, forKey: "recipient")
        aCoder.encode(isIncome, forKey: "isIncome")
        aCoder.encode(folderId, forKey: "folderId")
    }
}

extension MDMail: YapDatabaseRelationshipNode {
    
    func yapDatabaseRelationshipEdges() -> [YapDatabaseRelationshipEdge]? {
        let folderEdge = YapDatabaseRelationshipEdge(name: YapDbService.Edges.mailFolder.rawValue,
                                                     destinationKey: folderId,
                                                     collection: YapDbService.Collections.folders.rawValue,
                                                     nodeDeleteRules: .notifyIfDestinationDeleted)
        return [folderEdge]
    }
    
    func yapDatabaseRelationshipEdgeDeleted(_ edge: YapDatabaseRelationshipEdge, with reason: YDB_NotifyReason) -> Any? {
        switch reason {
        case .destinationNodeDeleted:
            return updated(folderId: FolderType.inbox.id)
        case .sourceNodeDeleted, .edgeDeleted:
            return nil
        }
    }
}
