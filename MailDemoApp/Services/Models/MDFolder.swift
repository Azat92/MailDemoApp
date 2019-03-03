//
//  MDFolder.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 04/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

enum FolderType {
    
    case inbox
    case outbox
    case drafts
    case spam
    case trash
    case custom
}

extension FolderType {
    
    var id: String {
        switch self {
        case .inbox:
            return "inbox"
        case .outbox:
            return "outbox"
        case .drafts:
            return "drafts"
        case .spam:
            return "spam"
        case .trash:
            return "trash"
        case .custom:
            return NSUUID().uuidString
        }
    }
}

class MDFolder: NSObject {

    let id: String
    let title: String
    let order: Int
    let isSystem: Bool
    let allowsMoveMails: Bool
    
    init(type: FolderType = .custom, title: String, order: Int, allowsMoveMails: Bool, isSystem: Bool = true) {
        self.id = type.id
        self.title = title
        self.order = order
        self.isSystem = isSystem
        self.allowsMoveMails = allowsMoveMails
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.order = aDecoder.decodeInteger(forKey: "order")
        self.isSystem = aDecoder.decodeBool(forKey: "isSystem")
        self.allowsMoveMails = aDecoder.decodeBool(forKey: "allowsMoveMails")
        super.init()
    }
}

extension MDFolder: NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(order, forKey: "order")
        aCoder.encode(isSystem, forKey: "isSystem")
        aCoder.encode(allowsMoveMails, forKey: "allowsMoveMails")
    }
}

extension MDFolder {
    
    var isReadOnly: Bool {
        return folderType != .drafts
    }
    
    var folderType: FolderType {
        switch id {
        case "inbox":
            return .inbox
        case "outbox":
            return .outbox
        case "drafts":
            return .drafts
        case "spam":
            return .spam
        case "trash":
            return .trash
        default:
            return .custom
        }
    }
}
