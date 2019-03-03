//
//  Localizations.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 24/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

enum Localizations {
    
    enum Common {
        
        static let ok = "OK"
        static let cancel = "Cancel"
        static let at = "at"
        static let chooseAction = "Choose action"
    }
    
    enum Folders {
        
        static let title = "Folders"
        static let addFolder = "Add folder"
        static let folderName = "Folder name"
        static let systemFolders = "System folders"
        static let customFolders = "User folders"
        static let chooseFolder = "Choose folder"
        
        enum System {
            
            static let inbox = "Inbox"
            static let outbox = "Outbox"
            static let drafts = "Drafts"
            static let spam = "Spam"
            static let trash = "Trash"
        }
    }
    
    enum Mail {
        
        static let title = "Mail"
        static let noSubject = "(No subject)"
        
        enum Actions {
            
            static let reply = "Reply"
            static let forward = "Forward"
            static let moveToFolder = "Move to folder"
            static let markAsSpam = "Spam"
            static let delete = "Delete"
            static let send = "Send"
        }
    }
}
