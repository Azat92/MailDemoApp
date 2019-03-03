//
//  MailViewOutput.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

enum MailAction {
    
    case reply
    case forward
    case moveToFolder
    case markAsSpam
    case delete
    case send
}

extension MailAction {
    
    var title: String {
        switch self {
        case .reply:
            return Localizations.Mail.Actions.reply
        case .forward:
            return Localizations.Mail.Actions.forward
        case .moveToFolder:
            return Localizations.Mail.Actions.moveToFolder
        case .markAsSpam:
            return Localizations.Mail.Actions.markAsSpam
        case .delete:
            return Localizations.Mail.Actions.delete
        case .send:
            return Localizations.Mail.Actions.send
        }
    }
}

protocol MailViewOutput {

    func viewIsReady()
    
    func handleUpdateMail(recipient: String?, subject: String?, body: String)
    
    func availableActions() -> [MailAction]
    
    func handle(action: MailAction)
    
    func handleMove(toFolder: MDFolder)
}
